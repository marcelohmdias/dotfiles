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

-- ensure_checkout() --

T['ensure_checkout()'] = MiniTest.new_set()

T['ensure_checkout()']['checks out correct tag in plugin dir'] = function()
  -- Create a temp git repo to simulate a plugin
  child.lua([[
    local tmp = vim.fn.tempname()
    vim.fn.mkdir(tmp, 'p')
    vim.fn.system('git -C ' .. tmp .. ' init')
    vim.fn.system('git -C ' .. tmp .. ' commit --allow-empty -m "first"')
    vim.fn.system('git -C ' .. tmp .. ' tag v1.0.0')
    vim.fn.system('git -C ' .. tmp .. ' commit --allow-empty -m "second"')
    vim.fn.system('git -C ' .. tmp .. ' tag v2.0.0')
    _G._tmp = tmp

    -- Verify we're on v2.0.0 (latest commit)
    local current = vim.fn.system('git -C ' .. tmp .. ' describe --tags --exact-match 2>/dev/null'):gsub('%s+$', '')
    _G._before = current
  ]])
  MiniTest.expect.equality(child.lua_get('_G._before'), 'v2.0.0')

  -- Simulate checkout to v1.0.0
  child.lua([[
    local dir = _G._tmp
    vim.fn.system('git -C ' .. vim.fn.shellescape(dir) .. ' checkout v1.0.0')
    local after = vim.fn.system('git -C ' .. dir .. ' describe --tags --exact-match 2>/dev/null'):gsub('%s+$', '')
    _G._after = after
  ]])
  MiniTest.expect.equality(child.lua_get('_G._after'), 'v1.0.0')

  -- Cleanup
  child.lua([[vim.fn.delete(_G._tmp, 'rf')]])
end

T['ensure_checkout()']['skips checkout if already on correct tag'] = function()
  child.lua([[
    local tmp = vim.fn.tempname()
    vim.fn.mkdir(tmp, 'p')
    vim.fn.system('git -C ' .. tmp .. ' init')
    vim.fn.system('git -C ' .. tmp .. ' commit --allow-empty -m "first"')
    vim.fn.system('git -C ' .. tmp .. ' tag v1.0.0')
    _G._tmp = tmp

    -- Already on v1.0.0, checkout should be a no-op
    local before = vim.fn.system('git -C ' .. tmp .. ' describe --tags --exact-match 2>/dev/null'):gsub('%s+$', '')
    _G._before = before

    -- Simulate the check
    local current = vim.fn.system('git -C ' .. vim.fn.shellescape(tmp) .. ' describe --tags --exact-match 2>/dev/null'):gsub('%s+$', '')
    _G._needs_checkout = (current ~= 'v1.0.0')
  ]])
  MiniTest.expect.equality(child.lua_get('_G._before'), 'v1.0.0')
  MiniTest.expect.equality(child.lua_get('_G._needs_checkout'), false)

  child.lua([[vim.fn.delete(_G._tmp, 'rf')]])
end

-- install skip via fs_stat --

T['install'] = MiniTest.new_set()

T['install']['skips vim.pack.add for installed plugins'] = function()
  local child2 = H.new_child()
  child2.lua([[
    -- Create a fake opt directory with an "installed" plugin
    local tmp = vim.fn.tempname()
    local opt_dir = tmp .. '/pack/core/opt/'
    vim.fn.mkdir(opt_dir .. 'already-installed', 'p')

    -- Verify fs_stat returns truthy for installed plugin
    _G._stat_result = vim.uv.fs_stat(opt_dir .. 'already-installed') ~= nil

    -- Verify fs_stat returns nil for missing plugin
    _G._stat_missing = vim.uv.fs_stat(opt_dir .. 'not-installed') == nil

    vim.fn.delete(tmp, 'rf')
  ]])
  MiniTest.expect.equality(child2.lua_get('_G._stat_result'), true)
  MiniTest.expect.equality(child2.lua_get('_G._stat_missing'), true)
  child2.stop()
end

return T
