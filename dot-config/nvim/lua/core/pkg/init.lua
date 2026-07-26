local M = {}

local resolver = require('core.pkg.resolver')
local spec_mod = require('core.pkg.spec')
local loader = require('core.pkg.loader')
local release_age = require('core.pkg.release_age')
local sources = require('core.pkg.sources')
local semver = require('core.pkg.semver')

--- All collected specs by name.
---@type table<string, table>
local all_specs = {}

-- Build execution ------------------------------------------------------------

--- Check if a plugin is active (sourced).
---@param name string
---@return boolean
local function is_active(name)
  return vim.fn.exists(':' .. name) > 0 or loader.is_loaded(name)
end

--- Execute build steps for a spec.
---@param spec table
local function execute_build(spec)
  if not spec.build then
    return
  end

  local plugin_dir = sources.PACK_PATH .. '/' .. spec.name
  local steps = type(spec.build) == 'table' and spec.build or { spec.build }
  for _, step in ipairs(steps) do
    MiniMisc.safely('now', function()
      if type(step) == 'function' then
        step()
      elseif type(step) == 'string' and step:sub(1, 1) == ':' then
        if not is_active(spec.name) then
          vim.cmd.packadd(spec.name)
        end
        vim.cmd(step:sub(2))
      elseif type(step) == 'string' then
        vim.fn.system('cd ' .. vim.fn.shellescape(plugin_dir) .. ' && ' .. step)
      end
    end)
  end
end

-- PackChanged hook -----------------------------------------------------------

local function register_pack_changed()
  autocmd('PackChanged', {
    callback = function(event)
      if event.data.kind ~= 'install' and event.data.kind ~= 'update' then
        return
      end
      local spec = all_specs[event.data.spec.name]
      if not spec then
        return
      end
      execute_build(spec)
    end,
  })
end

-- :MiniPack command ----------------------------------------------------------

local subcommands = {
  open = function()
    require('core.pkg.ui').open(all_specs)
  end,
  update = function()
    require('core.pkg.ui').update_all(all_specs)
  end,
  check = function()
    require('core.pkg.ui').check(function()
      local count = require('core.pkg.ui').pending_count()
      if count then
        vim.notify(string.format('[MiniPack] %d plugin(s) have updates available', count), vim.log.levels.INFO)
      else
        vim.notify('[MiniPack] All plugins are up to date', vim.log.levels.INFO)
      end
    end)
  end,
  clean = function()
    -- Collect names that are no longer declared
    local installed = vim.pack.list and vim.pack.list() or {}
    local to_del = {}
    for _, name in ipairs(installed) do
      if not all_specs[name] then
        to_del[#to_del + 1] = name
      end
    end
    if #to_del > 0 then
      vim.pack.del(to_del)
    else
      vim.notify('[MiniPack] Nothing to clean', vim.log.levels.INFO)
    end
  end,
  health = function()
    vim.cmd('checkhealth vim.pack')
  end,
  reload = function()
    vim.cmd('restart')
  end,
  test = function()
    require('core.pkg.ui').open(all_specs, { tab = 'tests' })
  end,
}

local function register_command()
  vim.api.nvim_create_user_command('MiniPack', function(args)
    local sub = args.fargs[1] or 'open'
    if not subcommands[sub] then
      vim.notify('[MiniPack] Available: ' .. table.concat(vim.tbl_keys(subcommands), ', '), vim.log.levels.INFO)
      return
    end
    subcommands[sub]()
  end, {
    nargs = '?',
    complete = function()
      return vim.tbl_keys(subcommands)
    end,
    desc = '[MiniPack] Plugin manager commands',
  })
end

-- Version resolution ---------------------------------------------------------

local TAG_CACHE_PATH = vim.fn.stdpath('data') .. '/minipack-tag-cache.json'

--- Load cached tag resolutions from disk.
---@return table<string, string> src → tag
local function load_tag_cache()
  local ok, content = pcall(vim.fn.readfile, TAG_CACHE_PATH)
  if not ok or not content or #content == 0 then
    return {}
  end
  local parse_ok, data = pcall(vim.json.decode, table.concat(content, '\n'))
  return parse_ok and type(data) == 'table' and data or {}
end

--- Save tag cache to disk.
---@param cache table<string, string>
local function save_tag_cache(cache)
  pcall(vim.fn.writefile, { vim.json.encode(cache) }, TAG_CACHE_PATH)
end

--- Ensure a plugin is checked out to the correct tag/version (async).
---@param spec table Normalized spec with checkout field set
---@param opt_dir string Path to opt/ directory
local function ensure_checkout(spec, opt_dir)
  if not spec.checkout or not spec.name then
    return
  end
  local plugin_dir = opt_dir .. spec.name
  if vim.fn.isdirectory(plugin_dir) ~= 1 then
    return
  end

  vim.system({ 'git', '-C', plugin_dir, 'describe', '--tags', '--exact-match' }, { text = true }, function(result)
    local current = (result.stdout or ''):gsub('%s+$', '')
    if current == spec.checkout then
      return
    end

    vim.system({ 'git', '-C', plugin_dir, 'fetch', '--tags', '--quiet' }, {}, function()
      vim.system({ 'git', '-C', plugin_dir, 'checkout', spec.checkout }, {})
    end)
  end)
end

-- Setup ----------------------------------------------------------------------

--- Main entry point. Resolves imports, installs, and loads plugins.
---@param opts { import: string, confirm?: boolean, minimum_release_age?: unknown, minimum_release_age_downgrade?: unknown }
function M.setup(opts)
  opts = opts or {}
  if not opts.import then
    vim.notify('[MiniPack] setup() requires { import = "..." }', vim.log.levels.ERROR)
    return
  end

  release_age.set_defaults(opts)

  -- 1. Resolve all specs from import chain
  local specs = resolver.resolve(opts.import)

  -- 2. Merge specs with same name, index by name
  local merged = {} ---@type table[]
  for _, spec in ipairs(specs) do
    if spec.name and all_specs[spec.name] then
      -- Merge into existing primary spec
      spec_mod.merge(all_specs[spec.name], spec)
    else
      if spec.name then
        all_specs[spec.name] = spec
      end
      merged[#merged + 1] = spec
    end
  end
  specs = merged

  -- 3. Separate lazy/eager
  local eager = {} ---@type table[]
  local lazy = {} ---@type table[]
  local blocked = {} ---@type table<string, string>

  for _, spec in ipairs(specs) do
    if spec.lazy == false then
      eager[#eager + 1] = spec
    else
      lazy[#lazy + 1] = spec
    end
  end

  -- 4. Register PackChanged hook for builds
  register_pack_changed()

  -- 5. Install plugins via vim.pack.add()
  -- Only call vim.pack.add() for plugins NOT yet on disk. Already-installed
  -- plugins are in opt/ and reachable via :packadd without any add() call.
  -- Missing lazy plugins are deferred to VeryLazy to avoid blocking startup.
  local eager_missing = {} ---@type table[]
  local lazy_missing = {} ---@type table[]
  local seen = {} ---@type table<string, boolean>
  local version_specs = {} ---@type table[] specs needing version resolution (deferred)
  local opt_dir = sources.PACK_PATH .. '/'

  ---@param spec table
  ---@return boolean
  local function has_blocked_dependency(spec)
    if not spec.dependencies then
      return false
    end
    for _, dep in ipairs(spec.dependencies) do
      if dep.name and blocked[dep.name] then
        return true
      end
    end
    return false
  end

  -- Build set of eager spec names for dependency classification
  local eager_names = {} ---@type table<string, boolean>
  for _, spec in ipairs(eager) do
    if spec.name then
      eager_names[spec.name] = true
    end
  end

  --- Collect a pack spec into the appropriate list (only if not installed).
  ---@param src string
  ---@param name string
  ---@param spec table Original spec (for version/checkout)
  ---@param is_eager boolean
  local function collect(src, name, spec, is_eager)
    if not src or seen[src] then
      return
    end
    seen[src] = true
    -- Track version specs regardless of install status (for checkout enforcement)
    if not spec.checkout and spec.version then
      version_specs[#version_specs + 1] = spec
    end
    -- Skip if already installed on disk
    if name and vim.uv.fs_stat(opt_dir .. name) then
      return
    end

    local policy = release_age.policy(spec)
    if policy.enabled then
      local resolved = release_age.resolve_remote(spec, policy)
      if not resolved.checkout then
        blocked[name] = string.format(
          '[MiniPack] %s is blocked by minimum_release_age (%s); %s',
          name,
          policy.label,
          release_age.pending_message()
        )
        return
      end
      spec.checkout = resolved.checkout
    end

    local pack_spec = { src = src, name = name }
    if spec.checkout then
      pack_spec.checkout = spec.checkout
    end
    if is_eager then
      eager_missing[#eager_missing + 1] = pack_spec
    else
      lazy_missing[#lazy_missing + 1] = pack_spec
    end
  end

  for _, spec in ipairs(specs) do
    local is_eager = spec.lazy == false
    -- Collect dependencies (inherit eagerness from parent)
    if spec.dependencies then
      for _, dep in ipairs(spec.dependencies) do
        collect(dep.src, dep.name, dep, is_eager or eager_names[dep.name] or false)
      end
    end
    collect(spec.src, spec.name, spec, is_eager)
  end

  if next(blocked) then
    local filtered = {} ---@type table[]
    for _, spec in ipairs(specs) do
      if not blocked[spec.name] and not has_blocked_dependency(spec) then
        filtered[#filtered + 1] = spec
      end
    end
    specs = filtered
    eager = {}
    lazy = {}
    for _, spec in ipairs(specs) do
      if spec.lazy == false then
        eager[#eager + 1] = spec
      else
        lazy[#lazy + 1] = spec
      end
    end
    for _, message in pairs(blocked) do
      vim.notify(message, vim.log.levels.ERROR)
    end
  end

  -- Install missing eager plugins immediately (needed before load_plugin)
  if #eager_missing > 0 then
    vim.pack.add(eager_missing, { confirm = opts.confirm })
  end
  -- Defer missing lazy plugin installation to VeryLazy
  if #lazy_missing > 0 then
    vim.api.nvim_create_autocmd('User', {
      pattern = 'VeryLazy',
      once = true,
      callback = function()
        vim.pack.add(lazy_missing, { confirm = opts.confirm, load = function() end })
      end,
    })
  end

  -- 5b. Version resolution: fully deferred to VeryLazy.
  -- Plugins are already at the correct tag from install/previous checkout.
  -- The async refresh resolves latest tags and updates cache + checkout.
  if #version_specs > 0 then
    vim.api.nvim_create_autocmd('User', {
      pattern = 'VeryLazy',
      once = true,
      callback = function()
        vim.schedule(function()
          local tag_cache = load_tag_cache()
          local remaining = 0
          local updated = false

          -- Separate specs: semver ranges need remote tag fetch, fixed versions don't
          local range_specs = {} ---@type table[]
          for _, spec in ipairs(version_specs) do
            local policy = release_age.policy(spec)
            if policy.enabled and spec.name and vim.uv.fs_stat(opt_dir .. spec.name) then
              local plugin_dir = opt_dir .. spec.name
              vim.system({ 'git', '-C', plugin_dir, 'fetch', '--tags', '--quiet' }, {}, function()
                vim.schedule(function()
                  local resolved = release_age.resolve_local(plugin_dir, spec, policy)
                  if resolved.checkout and resolved.actionable then
                    release_age.checkout(plugin_dir, resolved.checkout)
                  end
                end)
              end)
            elseif semver.is_range(spec.version) then
              remaining = remaining + 1
              local cached_tag = tag_cache[spec.src]
              if cached_tag then
                spec.checkout = cached_tag
              end
              range_specs[#range_specs + 1] = spec
            else
              -- Fixed version (branch name like 'main', exact ref)
              spec.checkout = spec.version
            end
          end

          if remaining == 0 then
            -- Only fixed-version specs: ensure checkout locally
            for _, spec in ipairs(version_specs) do
              ensure_checkout(spec, opt_dir)
            end
            return
          end

          for _, spec in ipairs(range_specs) do
            vim.system(
              { 'git', 'ls-remote', '--tags', '--sort=-v:refname', spec.src },
              { text = true },
              function(result)
                if result.code == 0 and result.stdout then
                  -- Parse all tags from ls-remote output
                  local tags = {}
                  for tag in result.stdout:gmatch('refs/tags/([^\n^{}]+)') do
                    tags[#tags + 1] = tag
                  end

                  local best = semver.best_match(tags, spec.version)
                  if best and best ~= tag_cache[spec.src] then
                    tag_cache[spec.src] = best
                    spec.checkout = best
                    updated = true
                    vim.schedule(function()
                      ensure_checkout(spec, opt_dir)
                    end)
                  end
                end

                remaining = remaining - 1
                if remaining == 0 and updated then
                  vim.schedule(function()
                    save_tag_cache(tag_cache)
                  end)
                end
              end
            )
          end
        end)
      end,
    })
  end

  -- 6. Register all specs in loader (for stats/dependency resolution)
  loader.register_specs(specs)

  -- 7. Load eager plugins immediately
  for _, spec in ipairs(eager) do
    loader.load_plugin(spec)
  end

  -- 8. Register lazy-load stubs
  loader.register_stubs(lazy)

  -- 8b. Override Snacks.dashboard.have_plugin() to use MiniPack specs.
  -- The default checks lazy.nvim's registry which doesn't exist here.
  if Snacks and Snacks.dashboard then
    Snacks.dashboard.have_plugin = function(name)
      return all_specs[name] ~= nil
    end
  end

  -- 9. Register custom events
  loader.register_very_lazy()
  loader.register_lazy_file()

  -- 10. Call init() for all specs
  for _, spec in ipairs(specs) do
    if spec.init then
      MiniMisc.safely('now', function()
        spec.init()
      end)
    end
  end

  -- 11. Register :MiniPack command
  register_command()

  require('core.pkg.ui').configure(all_specs)

  -- 12. Start periodic update check (every hour, deferred)
  vim.schedule(function()
    require('core.pkg.ui').start_check_timer()
  end)
end

return M
