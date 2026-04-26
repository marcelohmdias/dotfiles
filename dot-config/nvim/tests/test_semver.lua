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

-- parse() --

T['parse()'] = MiniTest.new_set()

T['parse()']['parses full semver'] = function()
  local v = child.lua_get([[require('core.pkg.semver').parse('1.2.3')]])
  MiniTest.expect.equality(v, { major = 1, minor = 2, patch = 3 })
end

T['parse()']['strips v prefix'] = function()
  local v = child.lua_get([[require('core.pkg.semver').parse('v1.2.3')]])
  MiniTest.expect.equality(v, { major = 1, minor = 2, patch = 3 })
end

T['parse()']['defaults missing minor and patch'] = function()
  local v = child.lua_get([[require('core.pkg.semver').parse('1')]])
  MiniTest.expect.equality(v, { major = 1, minor = 0, patch = 0 })
end

T['parse()']['defaults missing patch'] = function()
  local v = child.lua_get([[require('core.pkg.semver').parse('1.2')]])
  MiniTest.expect.equality(v, { major = 1, minor = 2, patch = 0 })
end

T['parse()']['returns nil for empty string'] = function()
  local v = child.lua_get([[require('core.pkg.semver').parse('')]])
  MiniTest.expect.equality(v, vim.NIL)
end

T['parse()']['returns nil for nil'] = function()
  local v = child.lua_get([[require('core.pkg.semver').parse(nil)]])
  MiniTest.expect.equality(v, vim.NIL)
end

-- compare() --

T['compare()'] = MiniTest.new_set()

T['compare()']['equal versions return 0'] = function()
  child.lua([[_G._r = require('core.pkg.semver').compare(require('core.pkg.semver').parse('1.2.3'), require('core.pkg.semver').parse('1.2.3'))]])
  MiniTest.expect.equality(child.lua_get('_G._r'), 0)
end

T['compare()']['greater major returns 1'] = function()
  child.lua([[_G._r = require('core.pkg.semver').compare(require('core.pkg.semver').parse('2.0.0'), require('core.pkg.semver').parse('1.9.9'))]])
  MiniTest.expect.equality(child.lua_get('_G._r'), 1)
end

T['compare()']['lesser minor returns -1'] = function()
  child.lua([[_G._r = require('core.pkg.semver').compare(require('core.pkg.semver').parse('1.1.0'), require('core.pkg.semver').parse('1.2.0'))]])
  MiniTest.expect.equality(child.lua_get('_G._r'), -1)
end

T['compare()']['patch difference'] = function()
  child.lua([[_G._r = require('core.pkg.semver').compare(require('core.pkg.semver').parse('1.2.4'), require('core.pkg.semver').parse('1.2.3'))]])
  MiniTest.expect.equality(child.lua_get('_G._r'), 1)
end

-- satisfies() --

T['satisfies()'] = MiniTest.new_set()

T['satisfies()']['wildcard matches anything'] = function()
  child.lua([[_G._r = require('core.pkg.semver').satisfies(require('core.pkg.semver').parse('5.0.0'), '*')]])
  MiniTest.expect.equality(child.lua_get('_G._r'), true)
end

T['satisfies()']['exact match'] = function()
  child.lua([[_G._r = require('core.pkg.semver').satisfies(require('core.pkg.semver').parse('1.2.3'), '1.2.3')]])
  MiniTest.expect.equality(child.lua_get('_G._r'), true)
end

T['satisfies()']['exact mismatch'] = function()
  child.lua([[_G._r = require('core.pkg.semver').satisfies(require('core.pkg.semver').parse('1.2.4'), '1.2.3')]])
  MiniTest.expect.equality(child.lua_get('_G._r'), false)
end

T['satisfies()']['caret major bump'] = function()
  -- ^1.2.3 → >=1.2.3, <2.0.0
  child.lua([[
    local s = require('core.pkg.semver')
    _G._r1 = s.satisfies(s.parse('1.9.9'), '^1.2.3')
    _G._r2 = s.satisfies(s.parse('2.0.0'), '^1.2.3')
    _G._r3 = s.satisfies(s.parse('1.2.3'), '^1.2.3')
    _G._r4 = s.satisfies(s.parse('1.2.2'), '^1.2.3')
  ]])
  MiniTest.expect.equality(child.lua_get('_G._r1'), true)
  MiniTest.expect.equality(child.lua_get('_G._r2'), false)
  MiniTest.expect.equality(child.lua_get('_G._r3'), true)
  MiniTest.expect.equality(child.lua_get('_G._r4'), false)
end

T['satisfies()']['caret zero major'] = function()
  -- ^0.2.3 → >=0.2.3, <0.3.0
  child.lua([[
    local s = require('core.pkg.semver')
    _G._r1 = s.satisfies(s.parse('0.2.9'), '^0.2.3')
    _G._r2 = s.satisfies(s.parse('0.3.0'), '^0.2.3')
    _G._r3 = s.satisfies(s.parse('0.2.3'), '^0.2.3')
  ]])
  MiniTest.expect.equality(child.lua_get('_G._r1'), true)
  MiniTest.expect.equality(child.lua_get('_G._r2'), false)
  MiniTest.expect.equality(child.lua_get('_G._r3'), true)
end

T['satisfies()']['caret zero minor'] = function()
  -- ^0.0.3 → >=0.0.3, <0.0.4
  child.lua([[
    local s = require('core.pkg.semver')
    _G._r1 = s.satisfies(s.parse('0.0.3'), '^0.0.3')
    _G._r2 = s.satisfies(s.parse('0.0.4'), '^0.0.3')
  ]])
  MiniTest.expect.equality(child.lua_get('_G._r1'), true)
  MiniTest.expect.equality(child.lua_get('_G._r2'), false)
end

T['satisfies()']['tilde range'] = function()
  -- ~1.2.3 → >=1.2.3, <1.3.0
  child.lua([[
    local s = require('core.pkg.semver')
    _G._r1 = s.satisfies(s.parse('1.2.9'), '~1.2.3')
    _G._r2 = s.satisfies(s.parse('1.3.0'), '~1.2.3')
    _G._r3 = s.satisfies(s.parse('1.2.3'), '~1.2.3')
  ]])
  MiniTest.expect.equality(child.lua_get('_G._r1'), true)
  MiniTest.expect.equality(child.lua_get('_G._r2'), false)
  MiniTest.expect.equality(child.lua_get('_G._r3'), true)
end

T['satisfies()']['gte range'] = function()
  child.lua([[
    local s = require('core.pkg.semver')
    _G._r1 = s.satisfies(s.parse('2.0.0'), '>=1.0.0')
    _G._r2 = s.satisfies(s.parse('0.9.0'), '>=1.0.0')
  ]])
  MiniTest.expect.equality(child.lua_get('_G._r1'), true)
  MiniTest.expect.equality(child.lua_get('_G._r2'), false)
end

-- best_match() --

T['best_match()'] = MiniTest.new_set()

T['best_match()']['wildcard picks latest'] = function()
  child.lua([[_G._r = require('core.pkg.semver').best_match({'v1.0.0', 'v2.0.0', 'v1.5.0'}, '*')]])
  MiniTest.expect.equality(child.lua_get('_G._r'), 'v2.0.0')
end

T['best_match()']['caret picks latest in range'] = function()
  child.lua([[_G._r = require('core.pkg.semver').best_match({'v1.0.0', 'v1.5.0', 'v2.0.0', 'v1.9.9'}, '^1.0.0')]])
  MiniTest.expect.equality(child.lua_get('_G._r'), 'v1.9.9')
end

T['best_match()']['returns nil when no match'] = function()
  child.lua([[_G._r = require('core.pkg.semver').best_match({'v1.0.0', 'v1.1.0'}, '^2.0.0')]])
  MiniTest.expect.equality(child.lua_get('_G._r'), vim.NIL)
end

T['best_match()']['tilde picks latest in minor'] = function()
  child.lua([[_G._r = require('core.pkg.semver').best_match({'v1.2.0', 'v1.2.5', 'v1.3.0', 'v1.2.9'}, '~1.2.0')]])
  MiniTest.expect.equality(child.lua_get('_G._r'), 'v1.2.9')
end

T['best_match()']['skips non-semver tags'] = function()
  child.lua([[_G._r = require('core.pkg.semver').best_match({'nightly', 'v1.0.0', 'latest', 'v1.1.0'}, '^1.0.0')]])
  MiniTest.expect.equality(child.lua_get('_G._r'), 'v1.1.0')
end

T['best_match()']['caret zero major picks correctly'] = function()
  child.lua([[_G._r = require('core.pkg.semver').best_match({'v0.1.0', 'v0.2.0', 'v0.2.5', 'v0.3.0'}, '^0.2.0')]])
  MiniTest.expect.equality(child.lua_get('_G._r'), 'v0.2.5')
end

-- is_range() --

T['is_range()'] = MiniTest.new_set()

T['is_range()']['wildcard is range'] = function()
  MiniTest.expect.equality(child.lua_get([[require('core.pkg.semver').is_range('*')]]), true)
end

T['is_range()']['caret is range'] = function()
  MiniTest.expect.equality(child.lua_get([[require('core.pkg.semver').is_range('^1.0')]]), true)
end

T['is_range()']['tilde is range'] = function()
  MiniTest.expect.equality(child.lua_get([[require('core.pkg.semver').is_range('~1.0')]]), true)
end

T['is_range()']['version number is range'] = function()
  MiniTest.expect.equality(child.lua_get([[require('core.pkg.semver').is_range('1.0')]]), true)
end

T['is_range()']['branch name is not range'] = function()
  MiniTest.expect.equality(child.lua_get([[require('core.pkg.semver').is_range('main')]]), false)
end

T['is_range()']['branch with number prefix is not range'] = function()
  MiniTest.expect.equality(child.lua_get([[require('core.pkg.semver').is_range('feat/123')]]), false)
end

return T
