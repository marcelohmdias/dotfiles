---@diagnostic disable: undefined-global
local H = require('tests.helpers')

local child = H.new_child()

local T = MiniTest.new_set({
  hooks = {
    post_once = function()
      child.stop()
    end,
  },
})

-- normalize() --

T['normalize()'] = MiniTest.new_set()

T['normalize()']['copies [1] to src'] = function()
  child.lua([[
    _G._s = { 'https://github.com/foo/bar' }
    require('core.pkg.spec').normalize(_G._s)
  ]])
  MiniTest.expect.equality(child.lua_get('_G._s.src'), 'https://github.com/foo/bar')
  MiniTest.expect.equality(child.lua_get('_G._s[1]'), vim.NIL)
end

T['normalize()']['does not overwrite existing src'] = function()
  child.lua([[
    _G._s = { 'https://github.com/other', src = 'https://github.com/foo/bar' }
    require('core.pkg.spec').normalize(_G._s)
  ]])
  MiniTest.expect.equality(child.lua_get('_G._s.src'), 'https://github.com/foo/bar')
end

T['normalize()']['derives name from src'] = function()
  child.lua([[
    _G._s = { src = 'https://github.com/foo/bar.nvim' }
    require('core.pkg.spec').normalize(_G._s)
  ]])
  MiniTest.expect.equality(child.lua_get('_G._s.name'), 'bar.nvim')
end

T['normalize()']['derives name from .git URL'] = function()
  child.lua([[
    _G._s = { src = 'https://github.com/foo/bar.git' }
    require('core.pkg.spec').normalize(_G._s)
  ]])
  MiniTest.expect.equality(child.lua_get('_G._s.name'), 'bar')
end

T['normalize()']['preserves existing name'] = function()
  child.lua([[
    _G._s = { src = 'https://github.com/foo/bar', name = 'custom' }
    require('core.pkg.spec').normalize(_G._s)
  ]])
  MiniTest.expect.equality(child.lua_get('_G._s.name'), 'custom')
end

T['normalize()']['defaults lazy to true'] = function()
  child.lua([[
    _G._s = { src = 'https://github.com/foo/bar' }
    require('core.pkg.spec').normalize(_G._s)
  ]])
  MiniTest.expect.equality(child.lua_get('_G._s.lazy'), true)
end

T['normalize()']['respects lazy = false'] = function()
  child.lua([[
    _G._s = { src = 'https://github.com/foo/bar', lazy = false }
    require('core.pkg.spec').normalize(_G._s)
  ]])
  MiniTest.expect.equality(child.lua_get('_G._s.lazy'), false)
end

T['normalize()']['resolves enabled function'] = function()
  child.lua([[
    _G._s = { src = 'https://github.com/foo/bar', enabled = function() return false end }
    require('core.pkg.spec').normalize(_G._s)
  ]])
  MiniTest.expect.equality(child.lua_get('_G._s.enabled'), false)
end

T['normalize()']['defaults enabled to true'] = function()
  child.lua([[
    _G._s = { src = 'https://github.com/foo/bar' }
    require('core.pkg.spec').normalize(_G._s)
  ]])
  MiniTest.expect.equality(child.lua_get('_G._s.enabled'), true)
end

T['normalize()']['converts string event to array'] = function()
  child.lua([[
    _G._s = { src = 'https://github.com/foo/bar', event = 'BufRead' }
    require('core.pkg.spec').normalize(_G._s)
  ]])
  MiniTest.expect.equality(child.lua_get('_G._s.event'), { 'BufRead' })
end

T['normalize()']['expands VeryLazy to User VeryLazy'] = function()
  child.lua([[
    _G._s = { src = 'https://github.com/foo/bar', event = 'VeryLazy' }
    require('core.pkg.spec').normalize(_G._s)
  ]])
  MiniTest.expect.equality(child.lua_get('_G._s.event'), { 'User VeryLazy' })
end

T['normalize()']['expands LazyFile to User LazyFile'] = function()
  child.lua([[
    _G._s = { src = 'https://github.com/foo/bar', event = 'LazyFile' }
    require('core.pkg.spec').normalize(_G._s)
  ]])
  MiniTest.expect.equality(child.lua_get('_G._s.event'), { 'User LazyFile' })
end

T['normalize()']['does not expand regular events'] = function()
  child.lua([[
    _G._s = { src = 'https://github.com/foo/bar', event = { 'BufReadPost', 'VeryLazy' } }
    require('core.pkg.spec').normalize(_G._s)
  ]])
  MiniTest.expect.equality(child.lua_get('_G._s.event'), { 'BufReadPost', 'User VeryLazy' })
end

T['normalize()']['converts ft to FileType event'] = function()
  child.lua([[
    _G._s = { src = 'https://github.com/foo/bar', ft = 'lua' }
    require('core.pkg.spec').normalize(_G._s)
  ]])
  MiniTest.expect.equality(child.lua_get('_G._s.event'), { 'FileType lua' })
end

T['normalize()']['converts ft array to FileType events'] = function()
  child.lua([[
    _G._s = { src = 'https://github.com/foo/bar', ft = { 'lua', 'python' } }
    require('core.pkg.spec').normalize(_G._s)
  ]])
  MiniTest.expect.equality(child.lua_get('_G._s.event'), { 'FileType lua', 'FileType python' })
end

T['normalize()']['merges ft with existing events'] = function()
  child.lua([[
    _G._s = { src = 'https://github.com/foo/bar', event = 'VeryLazy', ft = 'lua' }
    require('core.pkg.spec').normalize(_G._s)
  ]])
  MiniTest.expect.equality(child.lua_get('_G._s.event'), { 'User VeryLazy', 'FileType lua' })
end

T['normalize()']['converts string cmd to array'] = function()
  child.lua([[
    _G._s = { src = 'https://github.com/foo/bar', cmd = 'Foo' }
    require('core.pkg.spec').normalize(_G._s)
  ]])
  MiniTest.expect.equality(child.lua_get('_G._s.cmd'), { 'Foo' })
end

T['normalize()']['converts string dependencies to table entries'] = function()
  child.lua([[
    _G._s = { src = 'https://github.com/foo/bar', dependencies = 'https://github.com/foo/baz' }
    require('core.pkg.spec').normalize(_G._s)
  ]])
  MiniTest.expect.equality(child.lua_get('#_G._s.dependencies'), 1)
  MiniTest.expect.equality(child.lua_get('_G._s.dependencies[1].src'), 'https://github.com/foo/baz')
  MiniTest.expect.equality(child.lua_get('_G._s.dependencies[1].name'), 'baz')
end

T['normalize()']['normalizes array of string dependencies'] = function()
  child.lua([[
    _G._s = {
      src = 'https://github.com/foo/bar',
      dependencies = { 'https://github.com/a/dep1', 'https://github.com/b/dep2.nvim' },
    }
    require('core.pkg.spec').normalize(_G._s)
  ]])
  MiniTest.expect.equality(child.lua_get('#_G._s.dependencies'), 2)
  MiniTest.expect.equality(child.lua_get('_G._s.dependencies[1].src'), 'https://github.com/a/dep1')
  MiniTest.expect.equality(child.lua_get('_G._s.dependencies[1].name'), 'dep1')
  MiniTest.expect.equality(child.lua_get('_G._s.dependencies[2].src'), 'https://github.com/b/dep2.nvim')
  MiniTest.expect.equality(child.lua_get('_G._s.dependencies[2].name'), 'dep2.nvim')
end

T['normalize()']['accepts table dependencies with name'] = function()
  child.lua([[
    _G._s = {
      src = 'https://github.com/foo/bar',
      dependencies = {
        { 'https://github.com/a/dep1', name = 'custom-name' },
      },
    }
    require('core.pkg.spec').normalize(_G._s)
  ]])
  MiniTest.expect.equality(child.lua_get('#_G._s.dependencies'), 1)
  MiniTest.expect.equality(child.lua_get('_G._s.dependencies[1].src'), 'https://github.com/a/dep1')
  MiniTest.expect.equality(child.lua_get('_G._s.dependencies[1].name'), 'custom-name')
end

T['normalize()']['accepts table dependencies with src key'] = function()
  child.lua([[
    _G._s = {
      src = 'https://github.com/foo/bar',
      dependencies = {
        { src = 'https://github.com/a/dep1', name = 'my-dep' },
      },
    }
    require('core.pkg.spec').normalize(_G._s)
  ]])
  MiniTest.expect.equality(child.lua_get('#_G._s.dependencies'), 1)
  MiniTest.expect.equality(child.lua_get('_G._s.dependencies[1].src'), 'https://github.com/a/dep1')
  MiniTest.expect.equality(child.lua_get('_G._s.dependencies[1].name'), 'my-dep')
end

T['normalize()']['derives name for table dependencies without name'] = function()
  child.lua([[
    _G._s = {
      src = 'https://github.com/foo/bar',
      dependencies = {
        { 'https://github.com/a/some-plugin.nvim' },
      },
    }
    require('core.pkg.spec').normalize(_G._s)
  ]])
  MiniTest.expect.equality(child.lua_get('_G._s.dependencies[1].name'), 'some-plugin.nvim')
end

T['normalize()']['handles mixed string and table dependencies'] = function()
  child.lua([[
    _G._s = {
      src = 'https://github.com/foo/bar',
      dependencies = {
        'https://github.com/a/str-dep',
        { 'https://github.com/b/tbl-dep', name = 'custom' },
      },
    }
    require('core.pkg.spec').normalize(_G._s)
  ]])
  MiniTest.expect.equality(child.lua_get('#_G._s.dependencies'), 2)
  MiniTest.expect.equality(child.lua_get('_G._s.dependencies[1].src'), 'https://github.com/a/str-dep')
  MiniTest.expect.equality(child.lua_get('_G._s.dependencies[1].name'), 'str-dep')
  MiniTest.expect.equality(child.lua_get('_G._s.dependencies[2].src'), 'https://github.com/b/tbl-dep')
  MiniTest.expect.equality(child.lua_get('_G._s.dependencies[2].name'), 'custom')
end

T['normalize()']['derives name from .git URL in dependencies'] = function()
  child.lua([[
    _G._s = {
      src = 'https://github.com/foo/bar',
      dependencies = { 'https://github.com/a/dep.git' },
    }
    require('core.pkg.spec').normalize(_G._s)
  ]])
  MiniTest.expect.equality(child.lua_get('_G._s.dependencies[1].name'), 'dep')
end

-- validate() --

T['validate()'] = MiniTest.new_set()

T['validate()']['returns true for import-only spec'] = function()
  local r = child.lua_get([[require('core.pkg.spec').validate({ import = 'plugins.config.foo' })]])
  MiniTest.expect.equality(r, true)
end

T['validate()']['returns true for config-only spec (foundation)'] = function()
  child.lua([[_G._v = require('core.pkg.spec').validate({ config = function() end })]])
  MiniTest.expect.equality(child.lua_get('_G._v'), true)
end

T['validate()']['returns true for opts-only spec (foundation)'] = function()
  local r = child.lua_get([[require('core.pkg.spec').validate({ opts = { foo = true } })]])
  MiniTest.expect.equality(r, true)
end

T['validate()']['returns false for spec without src/import/config/opts'] = function()
  local r = child.lua_get([[require('core.pkg.spec').validate({ lazy = true })]])
  MiniTest.expect.equality(r, false)
end

T['validate()']['returns false for spec with src but no name'] = function()
  local r = child.lua_get([[require('core.pkg.spec').validate({ src = '' })]])
  MiniTest.expect.equality(r, false)
end

T['validate()']['returns true for valid spec with src and name'] = function()
  local r = child.lua_get([[require('core.pkg.spec').validate({ src = 'https://github.com/foo/bar', name = 'bar' })]])
  MiniTest.expect.equality(r, true)
end

-- resolve_opts() --

T['resolve_opts()'] = MiniTest.new_set()

T['resolve_opts()']['returns table opts directly'] = function()
  local r = child.lua_get([[require('core.pkg.spec').resolve_opts({ opts = { a = 1 } })]])
  MiniTest.expect.equality(r, { a = 1 })
end

T['resolve_opts()']['calls function opts'] = function()
  child.lua([[_G._r = require('core.pkg.spec').resolve_opts({ opts = function() return { b = 2 } end })]])
  MiniTest.expect.equality(child.lua_get('_G._r'), { b = 2 })
end

T['resolve_opts()']['returns empty table when no opts'] = function()
  local r = child.lua_get([[require('core.pkg.spec').resolve_opts({})]])
  MiniTest.expect.equality(r, {})
end

T['resolve_opts()']['returns empty table when function returns nil'] = function()
  child.lua([[_G._r = require('core.pkg.spec').resolve_opts({ opts = function() end })]])
  MiniTest.expect.equality(child.lua_get('_G._r'), {})
end

-- run_config() --

T['run_config()'] = MiniTest.new_set()

T['run_config()']['strips .nvim suffix for require'] = function()
  child.lua([[
    -- Mock module with setup
    package.loaded['flash'] = { setup = function(opts) _G._setup_opts = opts end }
    require('core.pkg.spec').run_config({ name = 'flash.nvim', opts = { foo = true } })
  ]])
  MiniTest.expect.equality(child.lua_get('_G._setup_opts'), { foo = true })
end

T['run_config()']['strips .lua suffix for require'] = function()
  child.lua([[
    package.loaded['some'] = { setup = function(opts) _G._setup_lua = opts end }
    require('core.pkg.spec').run_config({ name = 'some.lua', opts = { bar = 1 } })
  ]])
  MiniTest.expect.equality(child.lua_get('_G._setup_lua'), { bar = 1 })
end

T['run_config()']['strips nvim- prefix for require'] = function()
  child.lua([[
    package.loaded['lint'] = { setup = function(opts) _G._setup_prefix = opts end }
    require('core.pkg.spec').run_config({ name = 'nvim-lint', opts = { baz = 2 } })
  ]])
  MiniTest.expect.equality(child.lua_get('_G._setup_prefix'), { baz = 2 })
end

T['run_config()']['calls config function instead of require'] = function()
  child.lua([[
    _G._config_called = false
    require('core.pkg.spec').run_config({
      name = 'test',
      config = function() _G._config_called = true end,
    })
  ]])
  MiniTest.expect.equality(child.lua_get('_G._config_called'), true)
end

T['run_config()']['does nothing without opts or config'] = function()
  -- Should not error
  child.lua([[require('core.pkg.spec').run_config({ name = 'nonexistent-plugin-xyz' })]])
end

-- merge() -------------------------------------------------------------------

T['merge()'] = MiniTest.new_set()

T['merge()']['deep-merges opts tables'] = function()
  child.lua([[
    local spec = require('core.pkg.spec')
    _G._primary = { name = 'test', src = 'https://github.com/a/b', opts = { a = 1, nested = { x = 1 } } }
    spec.merge(_G._primary, { name = 'test', src = 'https://github.com/a/b', opts = { b = 2, nested = { y = 2 } } })
  ]])
  local result = child.lua_get('_G._primary.opts')
  MiniTest.expect.equality(result, { a = 1, b = 2, nested = { x = 1, y = 2 } })
end

T['merge()']['secondary opts override primary on conflict'] = function()
  child.lua([[
    local spec = require('core.pkg.spec')
    _G._primary = { name = 'test', opts = { a = 1 } }
    spec.merge(_G._primary, { name = 'test', opts = { a = 99 } })
  ]])
  local result = child.lua_get('_G._primary.opts')
  MiniTest.expect.equality(result, { a = 99 })
end

T['merge()']['concatenates keys'] = function()
  child.lua([[
    local spec = require('core.pkg.spec')
    _G._primary = { name = 'test', keys = { { '<leader>a' } } }
    spec.merge(_G._primary, { name = 'test', keys = { { '<leader>b' } } })
  ]])
  MiniTest.expect.equality(child.lua_get('#_G._primary.keys'), 2)
end

T['merge()']['concatenates event and cmd'] = function()
  child.lua([[
    local spec = require('core.pkg.spec')
    _G._primary = { name = 'test', event = { 'BufRead' }, cmd = { 'Foo' } }
    spec.merge(_G._primary, { name = 'test', event = { 'InsertEnter' }, cmd = { 'Bar' } })
  ]])
  MiniTest.expect.equality(child.lua_get('_G._primary.event'), { 'BufRead', 'InsertEnter' })
  MiniTest.expect.equality(child.lua_get('_G._primary.cmd'), { 'Foo', 'Bar' })
end

T['merge()']['preserves primary scalar fields'] = function()
  child.lua([[
    local spec = require('core.pkg.spec')
    _G._primary = { name = 'test', src = 'https://github.com/a/b', lazy = false }
    spec.merge(_G._primary, { name = 'test', src = 'https://github.com/a/b', lazy = true })
  ]])
  MiniTest.expect.equality(child.lua_get('_G._primary.lazy'), false)
end

T['merge()']['handles function opts in primary'] = function()
  child.lua([[
    local spec = require('core.pkg.spec')
    _G._primary = { name = 'test', opts = function() return { a = 1 } end }
    spec.merge(_G._primary, { name = 'test', opts = { b = 2 } })
  ]])
  local result = child.lua_get('_G._primary.opts()')
  MiniTest.expect.equality(result, { a = 1, b = 2 })
end

T['merge()']['creates keys list when primary has none'] = function()
  child.lua([[
    local spec = require('core.pkg.spec')
    _G._primary = { name = 'test' }
    spec.merge(_G._primary, { name = 'test', keys = { { '<leader>x' } } })
  ]])
  MiniTest.expect.equality(child.lua_get('#_G._primary.keys'), 1)
end

return T
