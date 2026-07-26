---@diagnostic disable: undefined-global
local H = require('tests.helpers')

local T = MiniTest.new_set()

-- Each test group gets a fresh child to avoid module caching issues

-- resolve_path (tested indirectly via resolve()) --

T['resolve()'] = MiniTest.new_set()

T['resolve()']['returns empty for missing import'] = function()
  local child = H.new_child()
  -- Point stdpath('config') to a temp dir with no lua/ files
  child.lua([[
    vim.env.XDG_CONFIG_HOME = vim.fn.tempname()
    vim.fn.mkdir(vim.env.XDG_CONFIG_HOME .. '/nvim/lua', 'p')
  ]])
  -- Force stdpath to use new XDG
  child.restart({ '-u', 'tests/minimal_init.lua' })
  child.lua([[
    vim.env.XDG_CONFIG_HOME = vim.fn.tempname()
    vim.fn.mkdir(vim.env.XDG_CONFIG_HOME .. '/nvim/lua', 'p')
  ]])
  local result = child.lua_get([[require('core.pkg.resolver').resolve('nonexistent.module')]])
  MiniTest.expect.equality(result, {})
  child.stop()
end

T['resolve()']['resolves a single file with specs'] = function()
  local child = H.new_child()

  child.lua([[
    local cfg = vim.fn.stdpath('config')
    _G._test_dir = cfg .. '/lua/_test_single'
    vim.fn.mkdir(_G._test_dir, 'p')
    local f = io.open(_G._test_dir .. '/foo.lua', 'w')
    f:write("return { { 'https://github.com/org/foo.nvim' } }")
    f:close()
  ]])

  local result = child.lua_get([[require('core.pkg.resolver').resolve('_test_single.foo')]])
  MiniTest.expect.equality(#result, 1)
  MiniTest.expect.equality(result[1].name, 'foo.nvim')

  child.lua([[vim.fn.delete(_G._test_dir, 'rf')]])
  child.stop()
end

T['resolve()']['resolves directory scanning'] = function()
  -- Use the real config dir — resolve 'plugins' should work if plugins dir exists
  local child = H.new_child()

  -- Create a temp spec file in a known location
  child.lua([[
    local cfg = vim.fn.stdpath('config')
    _G._test_dir = cfg .. '/lua/_test_resolve'
    vim.fn.mkdir(_G._test_dir, 'p')
    local f = io.open(_G._test_dir .. '/alpha.lua', 'w')
    f:write("return { { 'https://github.com/org/alpha.nvim' } }")
    f:close()
    local f2 = io.open(_G._test_dir .. '/beta.lua', 'w')
    f2:write("return { { 'https://github.com/org/beta.nvim', enabled = false } }")
    f2:close()
  ]])

  local result = child.lua_get([[require('core.pkg.resolver').resolve('_test_resolve')]])
  -- alpha should be included (enabled=true default), beta should be filtered (enabled=false)
  MiniTest.expect.equality(#result, 1)
  MiniTest.expect.equality(result[1].name, 'alpha.nvim')

  -- Cleanup
  child.lua([[vim.fn.delete(_G._test_dir, 'rf')]])
  child.stop()
end

T['resolve()']['resolves import chains recursively'] = function()
  local child = H.new_child()

  child.lua([[
    local cfg = vim.fn.stdpath('config')
    _G._test_dir = cfg .. '/lua/_test_chain'
    _G._test_sub = _G._test_dir .. '/sub'
    vim.fn.mkdir(_G._test_sub, 'p')

    -- index file with import
    local f = io.open(_G._test_dir .. '/index.lua', 'w')
    f:write("return { { import = '_test_chain.sub.actual' } }")
    f:close()

    -- actual spec
    local f2 = io.open(_G._test_sub .. '/actual.lua', 'w')
    f2:write("return { { 'https://github.com/org/chained.nvim' } }")
    f2:close()
  ]])

  local result = child.lua_get([[require('core.pkg.resolver').resolve('_test_chain.index')]])
  MiniTest.expect.equality(#result, 1)
  MiniTest.expect.equality(result[1].name, 'chained.nvim')

  -- Cleanup
  child.lua([[vim.fn.delete(_G._test_dir, 'rf')]])
  child.stop()
end

T['resolve()']['returns sorted modules from directory'] = function()
  local child = H.new_child()

  child.lua([[
    local cfg = vim.fn.stdpath('config')
    _G._test_dir = cfg .. '/lua/_test_sort'
    vim.fn.mkdir(_G._test_dir, 'p')

    for _, name in ipairs({ 'zebra', 'alpha', 'middle' }) do
      local f = io.open(_G._test_dir .. '/' .. name .. '.lua', 'w')
      f:write("return { { 'https://github.com/org/" .. name .. ".nvim' } }")
      f:close()
    end
  ]])

  local result = child.lua_get([[require('core.pkg.resolver').resolve('_test_sort')]])
  MiniTest.expect.equality(#result, 3)
  MiniTest.expect.equality(result[1].name, 'alpha.nvim')
  MiniTest.expect.equality(result[2].name, 'middle.nvim')
  MiniTest.expect.equality(result[3].name, 'zebra.nvim')

  -- Cleanup
  child.lua([[vim.fn.delete(_G._test_dir, 'rf')]])
  child.stop()
end

return T
