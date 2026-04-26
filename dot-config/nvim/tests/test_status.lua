---@diagnostic disable: undefined-global
local H = require('tests.helpers')

local T = MiniTest.new_set()

-- Helper: create child with MiniPack global and loader mock
local function make_child()
  local child = H.new_child()
  child.lua([[
    _G.MiniPack = { pending_count = function() return 0 end }
    _G.MiniMisc = { safely = function(_, f) f() end }
    _G.autocmd = function(event, opts)
      local group = vim.api.nvim_create_augroup('MiniPack_test', { clear = false })
      opts = vim.tbl_extend('force', { group = group }, opts or {})
      vim.api.nvim_create_autocmd(event, opts)
    end
  ]])
  return child
end

-- cputime() --

T['cputime()'] = MiniTest.new_set()

T['cputime()']['returns a positive number'] = function()
  local child = make_child()
  local t = child.lua_get([[require('core.pkg.status').cputime()]])
  MiniTest.expect.equality(type(t), 'number')
  MiniTest.expect.equality(t > 0, true)
  child.stop()
end

T['cputime()']['returns increasing values'] = function()
  local child = make_child()
  child.lua([[
    local s = require('core.pkg.status')
    _G._t1 = s.cputime()
    -- burn a little CPU
    for i = 1, 100000 do end
    _G._t2 = s.cputime()
  ]])
  local t1 = child.lua_get('_G._t1')
  local t2 = child.lua_get('_G._t2')
  MiniTest.expect.equality(t2 > t1, true)
  child.stop()
end

-- track() --

T['track()'] = MiniTest.new_set()

T['track()']['stores event time in _stats.times'] = function()
  local child = make_child()
  child.lua([[
    local s = require('core.pkg.status')
    s.track('TestEvent')
  ]])
  local t = child.lua_get([[require('core.pkg.status')._stats.times.TestEvent]])
  MiniTest.expect.equality(type(t), 'number')
  MiniTest.expect.equality(t > 0, true)
  child.stop()
end

-- on_ui_enter() --

T['on_ui_enter()'] = MiniTest.new_set()

T['on_ui_enter()']['sets startuptime'] = function()
  local child = make_child()
  child.lua([[
    local s = require('core.pkg.status')
    s.on_ui_enter()
  ]])
  local st = child.lua_get([[require('core.pkg.status')._stats.startuptime]])
  MiniTest.expect.equality(type(st), 'number')
  MiniTest.expect.equality(st > 0, true)
  child.stop()
end

-- stats() --

T['stats()'] = MiniTest.new_set()

T['stats()']['returns count and loaded from loader'] = function()
  local child = make_child()
  child.lua([[
    -- Use temp dir as pack path
    local tmp = vim.fn.tempname()
    local pack_path = tmp .. '/opt'
    vim.fn.mkdir(pack_path .. '/bar.nvim', 'p')
    vim.fn.mkdir(pack_path .. '/baz.nvim', 'p')

    local status = require('core.pkg.status')
    status._pack_path = pack_path
    status._foundation = {} -- no foundation for isolated test

    local loader = require('core.pkg.loader')
    local spec = require('core.pkg.spec')

    local s1 = { 'https://github.com/foo/bar.nvim', name = 'bar.nvim', opts = {} }
    spec.normalize(s1)
    local s2 = { 'https://github.com/foo/baz.nvim', name = 'baz.nvim', opts = {} }
    spec.normalize(s2)

    loader.register_stubs({ s1, s2 })

    vim.cmd.packadd = function() end
    loader.load_plugin(s1)

    _G._tmp = tmp
  ]])
  local stats = child.lua_get([[require('core.pkg.status').stats()]])
  MiniTest.expect.equality(stats.count, 2)
  MiniTest.expect.equality(stats.loaded, 1)
  child.lua([[vim.fn.delete(_G._tmp, 'rf')]])
  child.stop()
end

T['stats()']['returns zero counts when no plugins registered'] = function()
  local child = make_child()
  child.lua([[
    local tmp = vim.fn.tempname()
    vim.fn.mkdir(tmp, 'p')
    local status = require('core.pkg.status')
    status._pack_path = tmp
    status._foundation = {}
    _G._tmp = tmp
  ]])
  local stats = child.lua_get([[require('core.pkg.status').stats()]])
  MiniTest.expect.equality(stats.count, 0)
  MiniTest.expect.equality(stats.loaded, 0)
  child.lua([[vim.fn.delete(_G._tmp, 'rf')]])
  child.stop()
end

T['stats()']['includes foundation plugins in count and loaded'] = function()
  local child = make_child()
  child.lua([[
    local tmp = vim.fn.tempname()
    local pack_path = tmp .. '/opt'
    vim.fn.mkdir(pack_path .. '/mini.misc', 'p')
    vim.fn.mkdir(pack_path .. '/mini.icons', 'p')
    local status = require('core.pkg.status')
    status._pack_path = pack_path
    status._foundation = { 'mini.misc', 'mini.icons' }
    _G._tmp = tmp
  ]])
  local stats = child.lua_get([[require('core.pkg.status').stats()]])
  MiniTest.expect.equality(stats.count, 2)
  MiniTest.expect.equality(stats.loaded, 2)
  child.lua([[vim.fn.delete(_G._tmp, 'rf')]])
  child.stop()
end

-- updates() --

T['updates()'] = MiniTest.new_set()

T['updates()']['returns empty string when no updates'] = function()
  local child = make_child()
  local r = child.lua_get([[require('core.pkg.status').updates()]])
  MiniTest.expect.equality(r, '')
  child.stop()
end

T['updates()']['returns icon and count when updates available'] = function()
  local child = make_child()
  child.lua([[_G.MiniPack.pending_count = function() return 3 end]])
  local r = child.lua_get([[require('core.pkg.status').updates()]])
  MiniTest.expect.equality(r, ' 3')
  child.stop()
end

-- has_updates() --

T['has_updates()'] = MiniTest.new_set()

T['has_updates()']['returns false when no updates'] = function()
  local child = make_child()
  local r = child.lua_get([[require('core.pkg.status').has_updates()]])
  MiniTest.expect.equality(r, false)
  child.stop()
end

T['has_updates()']['returns true when updates available'] = function()
  local child = make_child()
  child.lua([[_G.MiniPack.pending_count = function() return 5 end]])
  local r = child.lua_get([[require('core.pkg.status').has_updates()]])
  MiniTest.expect.equality(r, true)
  child.stop()
end

-- plugin_stats() (loader) --

T['plugin_stats()'] = MiniTest.new_set()

T['plugin_stats()']['counts registered and loaded plugins'] = function()
  local child = make_child()
  child.lua([[
    local loader = require('core.pkg.loader')
    local spec = require('core.pkg.spec')

    local s1 = { 'https://github.com/a/one.nvim', name = 'one.nvim', opts = {} }
    spec.normalize(s1)
    local s2 = { 'https://github.com/a/two.nvim', name = 'two.nvim', opts = {} }
    spec.normalize(s2)
    local s3 = { 'https://github.com/a/three.nvim', name = 'three.nvim', opts = {} }
    spec.normalize(s3)

    loader.register_stubs({ s1, s2, s3 })
    vim.cmd.packadd = function() end
    loader.load_plugin(s1)
    loader.load_plugin(s2)

    _G._ps = loader.plugin_stats()
  ]])
  local ps = child.lua_get('_G._ps')
  MiniTest.expect.equality(ps.count, 3)
  MiniTest.expect.equality(ps.loaded, 2)
  child.stop()
end

return T
