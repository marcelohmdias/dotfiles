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

-- gh() --

T['gh()'] = MiniTest.new_set()

T['gh()']['expands org/repo to GitHub URL'] = function()
  local result = child.lua_get([[require('core.pkg.sources').gh('foo/bar')]])
  MiniTest.expect.equality(result, 'https://github.com/foo/bar')
end

T['gh()']['passes through full https URL'] = function()
  local result = child.lua_get([[require('core.pkg.sources').gh('https://example.com/repo')]])
  MiniTest.expect.equality(result, 'https://example.com/repo')
end

T['gh()']['passes through full http URL'] = function()
  local result = child.lua_get([[require('core.pkg.sources').gh('http://example.com/repo')]])
  MiniTest.expect.equality(result, 'http://example.com/repo')
end

-- cb() --

T['cb()'] = MiniTest.new_set()

T['cb()']['expands org/repo to Codeberg URL'] = function()
  local result = child.lua_get([[require('core.pkg.sources').cb('foo/bar')]])
  MiniTest.expect.equality(result, 'https://codeberg.org/foo/bar')
end

T['cb()']['passes through full https URL'] = function()
  local result = child.lua_get([[require('core.pkg.sources').cb('https://example.com/repo')]])
  MiniTest.expect.equality(result, 'https://example.com/repo')
end

return T
