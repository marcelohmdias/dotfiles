---@diagnostic disable: undefined-global
local H = require('tests.helpers')

local T = MiniTest.new_set()

-- Helper: create a child with MiniMisc mock and autocmd global
local function make_child()
  local child = H.new_child()
  child.lua([[
    -- Mock MiniMisc.safely so loader can work
    _G.MiniMisc = {
      safely = function(_, f) f() end,
    }
    -- Mock autocmd global (used by register_very_lazy/register_lazy_file)
    _G.autocmd = function(event, opts)
      local group = vim.api.nvim_create_augroup('MiniPack', { clear = false })
      opts = vim.tbl_extend('force', { group = group }, opts or {})
      vim.api.nvim_create_autocmd(event, opts)
    end
  ]])
  return child
end

-- is_loaded / has_key --

T['is_loaded()'] = MiniTest.new_set()

T['is_loaded()']['returns false for unloaded plugin'] = function()
  local child = make_child()
  local r = child.lua_get([[require('core.pkg.loader').is_loaded('nonexistent')]])
  MiniTest.expect.equality(r, false)
  child.stop()
end

T['has_key()'] = MiniTest.new_set()

T['has_key()']['returns false when no stubs registered'] = function()
  local child = make_child()
  local r = child.lua_get([[require('core.pkg.loader').has_key('<leader>x', 'n')]])
  MiniTest.expect.equality(r, false)
  child.stop()
end

-- register_stubs --

T['register_stubs()'] = MiniTest.new_set()

T['register_stubs()']['registers command stubs'] = function()
  local child = make_child()
  child.lua([[
    local loader = require('core.pkg.loader')
    loader.register_stubs({
      {
        name = 'test-plugin',
        src = 'https://github.com/org/test-plugin',
        cmd = { 'TestCmd' },
        lazy = true,
        enabled = true,
      },
    })
  ]])
  -- Verify command exists
  child.lua([[_G._cmd_exists = vim.api.nvim_get_commands({})['TestCmd'] ~= nil]])
  local exists = child.lua_get('_G._cmd_exists')
  MiniTest.expect.equality(exists, true)
  child.stop()
end

T['register_stubs()']['registers key stubs and has_key returns true'] = function()
  local child = make_child()
  child.lua([[
    local loader = require('core.pkg.loader')
    loader.register_stubs({
      {
        name = 'key-plugin',
        src = 'https://github.com/org/key-plugin',
        keys = { { '<leader>k', ':echo "hi"<CR>', mode = 'n', desc = 'Test key' } },
        lazy = true,
        enabled = true,
      },
    })
  ]])
  local r = child.lua_get([[require('core.pkg.loader').has_key('<leader>k', 'n')]])
  MiniTest.expect.equality(r, true)
  -- Other mode should be false
  local r2 = child.lua_get([[require('core.pkg.loader').has_key('<leader>k', 'v')]])
  MiniTest.expect.equality(r2, false)
  child.stop()
end

T['register_stubs()']['registers event stubs as autocmds'] = function()
  local child = make_child()
  child.lua([[
    local loader = require('core.pkg.loader')
    loader.register_stubs({
      {
        name = 'event-plugin',
        src = 'https://github.com/org/event-plugin',
        event = { 'BufRead' },
        lazy = true,
        enabled = true,
      },
    })
  ]])
  child.lua([[
    _G._aus = vim.api.nvim_get_autocmds({ group = 'MiniPack_stubs', event = 'BufRead' })
  ]])
  MiniTest.expect.equality(child.lua_get('#_G._aus > 0'), true)
  child.stop()
end

T['register_stubs()']['handles User event pattern'] = function()
  local child = make_child()
  child.lua([[
    local loader = require('core.pkg.loader')
    loader.register_stubs({
      {
        name = 'lazy-plugin',
        src = 'https://github.com/org/lazy-plugin',
        event = { 'User VeryLazy' },
        lazy = true,
        enabled = true,
      },
    })
  ]])
  child.lua([[
    _G._aus = vim.api.nvim_get_autocmds({ group = 'MiniPack_stubs', event = 'User' })
  ]])
  MiniTest.expect.equality(child.lua_get('#_G._aus > 0'), true)
  MiniTest.expect.equality(child.lua_get('_G._aus[1].pattern'), 'VeryLazy')
  child.stop()
end

-- load_plugin --

T['load_plugin()'] = MiniTest.new_set()

T['load_plugin()']['marks plugin as loaded'] = function()
  local child = make_child()
  child.lua([[
    local loader = require('core.pkg.loader')
    loader.register_stubs({
      {
        name = 'my-plugin',
        src = 'https://github.com/org/my-plugin',
        lazy = true,
        enabled = true,
      },
    })
    -- load_plugin needs spec from specs_by_name
    loader.load_plugin({ name = 'my-plugin', src = 'https://github.com/org/my-plugin' })
  ]])
  MiniTest.expect.equality(child.lua_get([[require('core.pkg.loader').is_loaded('my-plugin')]]), true)
  child.stop()
end

T['load_plugin()']['does not double-load'] = function()
  local child = make_child()
  child.lua([[
    _G._load_count = 0
    local loader = require('core.pkg.loader')
    local spec = {
      name = 'counter-plugin',
      config = function() _G._load_count = _G._load_count + 1 end,
    }
    loader.load_plugin(spec)
    loader.load_plugin(spec)
  ]])
  MiniTest.expect.equality(child.lua_get('_G._load_count'), 1)
  child.stop()
end

T['load_plugin()']['loads dep-only plugin via packadd fallback'] = function()
  local child = make_child()
  child.lua([[
    local loader = require('core.pkg.loader')
    -- Register a parent spec whose dep has no standalone spec
    loader.register_stubs({
      {
        name = 'parent-plugin',
        src = 'https://github.com/org/parent-plugin',
        dependencies = {
          { name = 'dep-only', src = 'https://github.com/org/dep-only' },
        },
        lazy = true,
        enabled = true,
      },
    })
    -- Track packadd calls
    _G._packadd_calls = {}
    vim.cmd.packadd = function(args)
      _G._packadd_calls[#_G._packadd_calls + 1] = type(args) == 'table' and args[1] or args
    end
    -- dep-only has no spec in specs_by_name, so load_plugin should packadd it directly
    loader.load_plugin({
      name = 'parent-plugin',
      src = 'https://github.com/org/parent-plugin',
      dependencies = {
        { name = 'dep-only', src = 'https://github.com/org/dep-only' },
      },
    })
  ]])
  -- dep-only should be marked as loaded
  MiniTest.expect.equality(child.lua_get([[require('core.pkg.loader').is_loaded('dep-only')]]), true)
  -- dep-only should appear in packadd calls
  MiniTest.expect.equality(child.lua_get([[vim.tbl_contains(_G._packadd_calls, 'dep-only')]]), true)
  child.stop()
end

T['load_plugin()']['event replay fires BufWinEnter for open buffers on LazyFile'] = function()
  local child = make_child()
  child.lua([[
    local loader = require('core.pkg.loader')
    -- Register a plugin triggered by LazyFile
    loader.register_stubs({
      {
        name = 'file-plugin',
        src = 'https://github.com/org/file-plugin',
        event = { 'User LazyFile' },
        lazy = true,
        enabled = true,
      },
    })
    -- Create a named buffer to simulate an already-open file
    local buf = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_buf_set_name(buf, '/tmp/test_replay.lua')
    vim.bo[buf].filetype = 'lua'
    vim.api.nvim_set_current_buf(buf)

    -- Track replayed events
    _G._replayed_events = {}
    vim.api.nvim_create_autocmd('BufWinEnter', {
      buffer = buf,
      callback = function() _G._replayed_events[#_G._replayed_events + 1] = 'BufWinEnter' end,
    })
    vim.api.nvim_create_autocmd('BufReadPost', {
      buffer = buf,
      callback = function() _G._replayed_events[#_G._replayed_events + 1] = 'BufReadPost' end,
    })
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'lua',
      callback = function() _G._replayed_events[#_G._replayed_events + 1] = 'FileType' end,
    })

    -- Fire LazyFile → should load plugin and replay events
    vim.api.nvim_exec_autocmds('User', { pattern = 'LazyFile' })
  ]])
  local replayed = child.lua_get('_G._replayed_events')
  MiniTest.expect.equality(vim.tbl_contains(replayed, 'BufReadPost'), true)
  MiniTest.expect.equality(vim.tbl_contains(replayed, 'BufWinEnter'), true)
  MiniTest.expect.equality(vim.tbl_contains(replayed, 'FileType'), true)
  child.stop()
end

-- register_very_lazy / register_lazy_file --

T['register_very_lazy()'] = MiniTest.new_set()

T['register_very_lazy()']['registers UIEnter autocmd'] = function()
  local child = make_child()
  child.lua([[require('core.pkg.loader').register_very_lazy()]])
  child.lua([[_G._aus = vim.api.nvim_get_autocmds({ group = 'MiniPack', event = 'UIEnter' })]])
  MiniTest.expect.equality(child.lua_get('#_G._aus > 0'), true)
  child.stop()
end

T['register_lazy_file()'] = MiniTest.new_set()

T['register_lazy_file()']['registers file event autocmds'] = function()
  local child = make_child()
  child.lua([[require('core.pkg.loader').register_lazy_file()]])
  child.lua([[
    _G._br = #vim.api.nvim_get_autocmds({ group = 'MiniPack', event = 'BufReadPost' })
    _G._bn = #vim.api.nvim_get_autocmds({ group = 'MiniPack', event = 'BufNewFile' })
    _G._bw = #vim.api.nvim_get_autocmds({ group = 'MiniPack', event = 'BufWritePre' })
  ]])
  MiniTest.expect.equality(child.lua_get('_G._br > 0'), true)
  MiniTest.expect.equality(child.lua_get('_G._bn > 0'), true)
  MiniTest.expect.equality(child.lua_get('_G._bw > 0'), true)
  child.stop()
end

T['register_lazy_file()']['skips BufNewFile for unnamed empty buffers'] = function()
  local child = make_child()
  child.lua([[
    _G._lazy_file_fired = false
    require('core.pkg.loader').register_lazy_file()
    vim.api.nvim_create_autocmd('User', {
      pattern = 'LazyFile',
      callback = function() _G._lazy_file_fired = true end,
    })
    -- Simulate BufNewFile on unnamed buffer (like dashboard)
    vim.api.nvim_exec_autocmds('BufNewFile', { buffer = 0 })
    vim.wait(100, function() return _G._lazy_file_fired end)
  ]])
  MiniTest.expect.equality(child.lua_get('_G._lazy_file_fired'), false)
  child.stop()
end

T['register_lazy_file()']['skips BufNewFile for nofile buftype'] = function()
  local child = make_child()
  child.lua([[
    _G._lazy_file_fired = false
    require('core.pkg.loader').register_lazy_file()
    vim.api.nvim_create_autocmd('User', {
      pattern = 'LazyFile',
      callback = function() _G._lazy_file_fired = true end,
    })
    -- Create a nofile buffer and trigger BufNewFile
    local buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].buftype = 'nofile'
    vim.api.nvim_exec_autocmds('BufNewFile', { buffer = buf })
    vim.wait(100, function() return _G._lazy_file_fired end)
  ]])
  MiniTest.expect.equality(child.lua_get('_G._lazy_file_fired'), false)
  child.stop()
end

T['register_lazy_file()']['fires on BufNewFile for named buffer'] = function()
  local child = make_child()
  child.lua([[
    _G._lazy_file_fired = false
    require('core.pkg.loader').register_lazy_file()
    vim.api.nvim_create_autocmd('User', {
      pattern = 'LazyFile',
      callback = function() _G._lazy_file_fired = true end,
    })
    -- Create a named buffer and trigger BufNewFile
    local buf = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_buf_set_name(buf, '/tmp/test_lazy_file.lua')
    vim.api.nvim_exec_autocmds('BufNewFile', { buffer = buf })
    vim.wait(200, function() return _G._lazy_file_fired end)
  ]])
  MiniTest.expect.equality(child.lua_get('_G._lazy_file_fired'), true)
  child.stop()
end

T['register_lazy_file()']['fires on BufReadPost'] = function()
  local child = make_child()
  child.lua([[
    _G._lazy_file_fired = false
    require('core.pkg.loader').register_lazy_file()
    vim.api.nvim_create_autocmd('User', {
      pattern = 'LazyFile',
      callback = function() _G._lazy_file_fired = true end,
    })
    vim.api.nvim_exec_autocmds('BufReadPost', { buffer = 0 })
    vim.wait(200, function() return _G._lazy_file_fired end)
  ]])
  MiniTest.expect.equality(child.lua_get('_G._lazy_file_fired'), true)
  child.stop()
end

T['register_lazy_file()']['fires only once'] = function()
  local child = make_child()
  child.lua([[
    _G._lazy_file_count = 0
    require('core.pkg.loader').register_lazy_file()
    vim.api.nvim_create_autocmd('User', {
      pattern = 'LazyFile',
      callback = function() _G._lazy_file_count = _G._lazy_file_count + 1 end,
    })
    vim.api.nvim_exec_autocmds('BufReadPost', { buffer = 0 })
    vim.wait(200, function() return _G._lazy_file_count > 0 end)
    vim.api.nvim_exec_autocmds('BufReadPost', { buffer = 0 })
    vim.wait(100, function() return _G._lazy_file_count > 1 end)
  ]])
  MiniTest.expect.equality(child.lua_get('_G._lazy_file_count'), 1)
  child.stop()
end

return T
