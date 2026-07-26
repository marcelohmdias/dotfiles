local M = {}

local spec_util = require('core.pkg.spec')

--- Loaded plugins tracker.
---@type table<string, boolean>
local loaded = {}

--- Load times tracker: load_times[name] = elapsed_ms
---@type table<string, number>
local load_times = {}

--- Key stubs tracker: key_stubs[lhs][mode] = true
---@type table<string, table<string, boolean>>
local key_stubs = {}

--- All specs by name (set by register_stubs).
---@type table<string, table>
local specs_by_name = {}

--- Index: src URL → spec name (for O(1) dependency lookup).
---@type table<string, string>
local src_to_name = {}

--- Event stubs group.
local STUB_GROUP = vim.api.nvim_create_augroup('MiniPack_stubs', { clear = true })

--- Normalize modes from a key entry.
---@param key table
---@return string[]
local function key_modes(key)
  local modes = key.mode or 'n'
  return type(modes) == 'string' and { modes } or modes
end

-- Load plugin ----------------------------------------------------------------

--- Load a single plugin and its dependencies.
---@param spec table Normalized spec
---@param defer? boolean Use bang for packadd (defer sourcing)
function M.load_plugin(spec, defer)
  if not spec or not spec.name then return end
  if loaded[spec.name] then return end
  loaded[spec.name] = true

  local t0 = vim.uv.hrtime()

  -- Load dependencies first
  if spec.dependencies then
    for _, dep in ipairs(spec.dependencies) do
      local dep_src = dep.src
      local dep_name = src_to_name[dep_src]
      local dep_spec = dep_name and specs_by_name[dep_name]
      if dep_spec then
        M.load_plugin(dep_spec, defer)
      elseif dep.name then
        -- Dependency-only plugin (no standalone spec): packadd directly
        if not loaded[dep.name] then
          loaded[dep.name] = true
          MiniMisc.safely('now', function()
            vim.cmd.packadd({ dep.name, bang = defer or false })
          end)
        end
      end
    end
  end

  -- packadd (only if has src)
  if spec.src then
    MiniMisc.safely('now', function()
      vim.cmd.packadd({ spec.name, bang = defer or false })
    end)
  end

  -- Run config
  MiniMisc.safely('now', function()
    spec_util.run_config(spec)
  end)

  -- Register keymaps for eager specs (lazy specs use key stubs instead)
  if spec.keys and spec.lazy == false then
    for _, key in ipairs(spec.keys) do
      local lhs = key[1]
      local rhs = key[2]
      if lhs and rhs then
        local modes = key_modes(key)
        vim.keymap.set(modes, lhs, rhs, {
          desc = key.desc,
          silent = true,
          remap = key.remap,
          buffer = key.buffer,
        })
      end
    end
  end

  load_times[spec.name] = (vim.uv.hrtime() - t0) / 1e6
end

--- Check if plugin is loaded.
---@param name string
---@return boolean
function M.is_loaded(name)
  return loaded[name] == true
end

-- Key stubs ------------------------------------------------------------------

--- Check if a lazy-load key stub exists for lhs+mode.
---@param lhs string
---@param mode string
---@return boolean
function M.has_key(lhs, mode)
  return key_stubs[lhs] ~= nil and key_stubs[lhs][mode] == true
end

--- Register key stubs for a spec's keys field.
--- NOTE: Uses vim.keymap.set/del directly (not global map()) because
--- map() filters via has_key(), which would create a circular dependency.
---@param spec table
local function register_key_stubs(spec)
  if not spec.keys then return end

  for _, key in ipairs(spec.keys) do
    local lhs = key[1]
    if not lhs then goto continue end

    local rhs = key[2]
    local modes = key_modes(key)

    for _, mode in ipairs(modes) do
      key_stubs[lhs] = key_stubs[lhs] or {}
      key_stubs[lhs][mode] = true

      vim.keymap.set(mode, lhs, function()
        -- Remove all key stubs for this spec
        for _, k in ipairs(spec.keys) do
          for _, m in ipairs(key_modes(k)) do
            pcall(vim.keymap.del, m, k[1])
            if key_stubs[k[1]] then
              key_stubs[k[1]][m] = nil
            end
          end
        end

        -- Load plugin
        M.load_plugin(spec)

        -- Set real mappings for all keys with rhs
        for _, k in ipairs(spec.keys) do
          if k[2] then
            vim.keymap.set(key_modes(k), k[1], k[2], {
              desc = k.desc,
              silent = true,
              remap = k.remap,
              buffer = k.buffer,
            })
          end
        end

        -- Replay the key that triggered the load
        local feed = vim.api.nvim_replace_termcodes(lhs, true, true, true)
        vim.api.nvim_feedkeys(feed, 'm', false)
      end, { desc = key.desc, silent = true })
    end

    ::continue::
  end
end

-- Event stubs ----------------------------------------------------------------

--- Register event stubs for lazy-loaded specs.
---@param specs table[] List of specs that have event triggers
local function register_event_stubs(specs)
  -- Collect specs per event
  local event_specs = {} ---@type table<string, table[]>

  for _, spec in ipairs(specs) do
    if spec.event then
      for _, event in ipairs(spec.event) do
        event_specs[event] = event_specs[event] or {}
        event_specs[event][#event_specs[event] + 1] = spec
      end
    end
  end

  -- Create one autocmd per distinct event
  for event, ev_specs in pairs(event_specs) do
    local pattern = nil
    local ev = event

    -- Handle 'Event Pattern' syntax (e.g. 'User VeryLazy', 'FileType lua')
    if event:match(' ') then
      ev, pattern = event:match('^(%S+)%s+(.+)$')
    end

    vim.api.nvim_create_autocmd(ev, {
      group = STUB_GROUP,
      pattern = pattern,
      once = true,
      callback = function(args)
        for _, spec in ipairs(ev_specs) do
          M.load_plugin(spec)
        end

        -- Replay events so loaded plugins can detect already-open buffers
        if ev == 'FileType' then
          vim.api.nvim_exec_autocmds('BufReadPre', { buffer = args.buf })
          vim.api.nvim_exec_autocmds('BufReadPost', { buffer = args.buf })
          vim.api.nvim_exec_autocmds('FileType', { pattern = args.match })
        elseif ev == 'User' and (pattern == 'LazyFile' or pattern == 'VeryLazy') then
          -- Re-trigger file events for all listed buffers so plugins can attach
          for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == '' then
              local name = vim.api.nvim_buf_get_name(buf)
              if name ~= '' then
                vim.api.nvim_exec_autocmds('BufReadPost', { buffer = buf })
                vim.api.nvim_exec_autocmds('BufWinEnter', { buffer = buf })
                local ft = vim.bo[buf].filetype
                if ft ~= '' then
                  vim.api.nvim_exec_autocmds('FileType', { pattern = ft })
                end
              end
            end
          end
        end
      end,
    })
  end
end

-- Command stubs --------------------------------------------------------------

--- Register command stubs for lazy-loaded specs.
---@param specs table[] List of specs that have cmd triggers
local function register_cmd_stubs(specs)
  for _, spec in ipairs(specs) do
    if not spec.cmd then goto continue end

    for _, command in ipairs(spec.cmd) do
      vim.api.nvim_create_user_command(command, function(args)
        -- Delete all command stubs for this spec
        for _, c in ipairs(spec.cmd) do
          pcall(vim.api.nvim_del_user_command, c)
        end

        M.load_plugin(spec)

        -- Replay command with original args
        local replay = args.bang and (command .. '!') or command
        if args.args and args.args ~= '' then
          replay = replay .. ' ' .. args.args
        end
        vim.cmd(replay)
      end, {
        bang = true,
        nargs = '*',
        range = true,
        complete = function(_, line)
          for _, c in ipairs(spec.cmd) do
            pcall(vim.api.nvim_del_user_command, c)
          end
          M.load_plugin(spec)
          return vim.fn.getcompletion(line, 'cmdline')
        end,
      })
    end

    ::continue::
  end
end

-- Custom events --------------------------------------------------------------

--- Register VeryLazy custom event (fires after UIEnter + vim.schedule).
function M.register_very_lazy()
  autocmd('UIEnter', {
    once = true,
    callback = function()
      vim.schedule(function()
        vim.api.nvim_exec_autocmds('User', { pattern = 'VeryLazy' })
      end)
    end,
  })
end

--- Register LazyFile custom event (fires on first file buffer event).
function M.register_lazy_file()
  local fired = false
  autocmd({ 'BufReadPost', 'BufNewFile', 'BufWritePre' }, {
    callback = function(ev)
      if fired then return true end -- delete autocmd
      -- Skip unnamed empty buffers (e.g. dashboard, startup screen)
      if ev.event == 'BufNewFile' then
        local name = vim.api.nvim_buf_get_name(ev.buf)
        if name == '' or vim.bo[ev.buf].buftype ~= '' then
          return
        end
      end
      fired = true
      vim.schedule(function()
        vim.api.nvim_exec_autocmds('User', { pattern = 'LazyFile' })
      end)
      return true -- delete autocmd
    end,
  })
end

-- Public API -----------------------------------------------------------------

--- Register all lazy-load stubs for a list of specs.
---@param specs table[] Normalized specs (lazy = true only)
function M.register_stubs(specs)
  -- Index specs by name and src
  for _, spec in ipairs(specs) do
    if spec.name then
      specs_by_name[spec.name] = spec
      if spec.src then src_to_name[spec.src] = spec.name end
    end
  end

  register_event_stubs(specs)
  register_cmd_stubs(specs)

  for _, spec in ipairs(specs) do
    register_key_stubs(spec)
  end
end

--- Register specs by name (for eager plugins that skip register_stubs).
---@param specs table[] Normalized specs
function M.register_specs(specs)
  for _, spec in ipairs(specs) do
    if spec.name then
      specs_by_name[spec.name] = spec
      if spec.src then src_to_name[spec.src] = spec.name end
    end
  end
end

--- Get plugin stats (count/loaded).
---@return { count: number, loaded: number }
function M.plugin_stats()
  local count = 0
  local loaded_count = 0
  for name, _ in pairs(specs_by_name) do
    count = count + 1
    if loaded[name] then
      loaded_count = loaded_count + 1
    end
  end
  return { count = count, loaded = loaded_count }
end

--- Get load time for a plugin (ms).
---@param name string
---@return number?
function M.load_time(name)
  return load_times[name]
end

--- Get all load times.
---@return table<string, number>
function M.load_times()
  return load_times
end

return M
