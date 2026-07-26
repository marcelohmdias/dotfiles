---@diagnostic disable: undefined-global
local H = require('tests.helpers')

local T = MiniTest.new_set()

--- Create a child with mocks needed for UI tests.
local function make_child()
  local child = H.new_child()
  child.lua([[
    _G.MiniMisc = { safely = function(_, f) f() end }
    _G.autocmd = function(event, opts)
      local group = vim.api.nvim_create_augroup('MiniPack', { clear = false })
      opts = vim.tbl_extend('force', { group = group }, opts or {})
      vim.api.nvim_create_autocmd(event, opts)
    end
    _G.cmd = function(c) return function() vim.cmd(c) end end
    _G.gh = function(src) return 'https://github.com/' .. src end
    _G.cb = function(src) return 'https://codeberg.org/' .. src end

    _G.ui = require('core.pkg.ui')
    _G.icons = require('core.icons')
  ]])
  return child
end

-- build_plugin_entry (real function) -----------------------------------------

T['build_plugin_entry()'] = MiniTest.new_set()

T['build_plugin_entry()']['returns line with org/repo, branch, hash'] = function()
  local child = make_child()
  child.lua([[
    _G.ui._set_specs({ ['snacks.nvim'] = { src = 'https://github.com/folke/snacks.nvim' } })
    _G.ui._set_git_cache({ ['snacks.nvim'] = { org = 'folke', repo = 'snacks.nvim', branch = 'main', hash = 'abc1234' } })
    _G._entry = _G.ui._build_plugin_entry('snacks.nvim')
  ]])
  local entry = child.lua_get('_G._entry')

  MiniTest.expect.equality(entry.line:find('folke/snacks%.nvim') ~= nil, true)
  MiniTest.expect.equality(entry.line:find(' %- main %- ') ~= nil, true)
  MiniTest.expect.equality(entry.line:find('abc1234', 1, true) ~= nil, true)
  child.stop()
end

T['build_plugin_entry()']['shows update available when has_update'] = function()
  local child = make_child()
  child.lua([[
    _G.ui._set_specs({ ['foo.nvim'] = { src = 'https://github.com/org/foo.nvim' } })
    _G.ui._set_git_cache({ ['foo.nvim'] = { org = 'org', repo = 'foo.nvim', branch = 'main', hash = 'abc1234', has_update = true } })
    _G._entry = _G.ui._build_plugin_entry('foo.nvim')
  ]])
  local entry = child.lua_get('_G._entry')

  MiniTest.expect.equality(entry.line:find('update available', 1, true) ~= nil, true)
  child.stop()
end

T['build_plugin_entry()']['shows updating when updating'] = function()
  local child = make_child()
  child.lua([[
    _G.ui._set_specs({ ['foo.nvim'] = { src = 'https://github.com/org/foo.nvim' } })
    _G.ui._set_git_cache({ ['foo.nvim'] = { org = 'org', repo = 'foo.nvim', branch = 'main', hash = 'abc1234', updating = true } })
    _G._entry = _G.ui._build_plugin_entry('foo.nvim')
  ]])
  local entry = child.lua_get('_G._entry')

  MiniTest.expect.equality(entry.line:find('updating', 1, true) ~= nil, true)
  child.stop()
end

T['build_plugin_entry()']['uses ellipsis when no git info'] = function()
  local child = make_child()
  child.lua([[
    _G.ui._set_specs({ ['foo.nvim'] = { src = 'https://github.com/org/foo.nvim' } })
    _G.ui._set_git_cache({})
    _G._entry = _G.ui._build_plugin_entry('foo.nvim')
  ]])
  local entry = child.lua_get('_G._entry')
  local line = entry.line

  -- Two distinct ellipsis (branch and hash)
  local first = line:find('…', 1, true)
  MiniTest.expect.equality(first ~= nil, true)
  local second = line:find('…', first + #'…', true)
  MiniTest.expect.equality(second ~= nil, true)
  MiniTest.expect.equality(second > first, true)
  child.stop()
end

T['build_plugin_entry()']['respects pending_updates over git_cache'] = function()
  local child = make_child()
  child.lua([[
    _G.ui._set_specs({ ['foo.nvim'] = { src = 'https://github.com/org/foo.nvim' } })
    _G.ui._set_git_cache({ ['foo.nvim'] = { org = 'org', repo = 'foo.nvim', branch = 'main', hash = 'abc1234', has_update = false } })
    _G.ui._set_pending_updates({ ['foo.nvim'] = true })
    _G._entry = _G.ui._build_plugin_entry('foo.nvim')
  ]])
  local entry = child.lua_get('_G._entry')

  MiniTest.expect.equality(entry.line:find('update available', 1, true) ~= nil, true)
  child.stop()
end

T['build_plugin_entry()']['shows pending label without update available'] = function()
  local child = make_child()
  child.lua([[
    _G.ui._set_specs({ ['foo.nvim'] = { src = 'https://github.com/org/foo.nvim' } })
    _G.ui._set_git_cache({ ['foo.nvim'] = { org = 'org', repo = 'foo.nvim', branch = 'main', hash = 'abc1234', has_update = true } })
    _G.ui._set_pending_updates({ ['foo.nvim'] = { kind = 'pending', pending_label = 'available in 3 dias' } })
    _G._entry = _G.ui._build_plugin_entry('foo.nvim')
  ]])
  local entry = child.lua_get('_G._entry')

  MiniTest.expect.equality(entry.line:find('available in 3 dias', 1, true) ~= nil, true)
  MiniTest.expect.equality(entry.line:find('update available', 1, true) == nil, true)
  child.stop()
end

-- hl_plugin_entry (real highlight calls) -------------------------------------

T['hl_plugin_entry()'] = MiniTest.new_set()

T['hl_plugin_entry()']['applies correct highlight groups'] = function()
  local child = make_child()
  child.lua([[
    _G.ui._set_specs({ ['foo.nvim'] = { src = 'https://github.com/org/foo.nvim' } })
    _G.ui._set_git_cache({ ['foo.nvim'] = { org = 'org', repo = 'foo.nvim', branch = 'main', hash = 'abc1234' } })
    local entry = _G.ui._build_plugin_entry('foo.nvim')

    _G._hls = {}
    local function hl(line, col_start, col_end, group)
      _G._hls[#_G._hls + 1] = { line = line, col_start = col_start, col_end = col_end, group = group }
    end
    _G.ui._hl_plugin_entry(entry, 0, hl, 'MiniPackBullet')
  ]])
  local hls = child.lua_get('_G._hls')

  local groups = {}
  for _, h in ipairs(hls) do
    groups[h.group] = true
  end
  MiniTest.expect.equality(groups['MiniPackBullet'], true)
  MiniTest.expect.equality(groups['MiniPackName'], true)
  MiniTest.expect.equality(groups['MiniPackBranch'], true)
  MiniTest.expect.equality(groups['MiniPackHash'], true)
  child.stop()
end

T['hl_plugin_entry()']['uses update highlight when has_update'] = function()
  local child = make_child()
  child.lua([[
    _G.ui._set_specs({ ['foo.nvim'] = { src = 'https://github.com/org/foo.nvim' } })
    _G.ui._set_git_cache({ ['foo.nvim'] = { org = 'org', repo = 'foo.nvim', branch = 'main', hash = 'abc1234', has_update = true } })
    local entry = _G.ui._build_plugin_entry('foo.nvim')

    _G._hls = {}
    local function hl(line, col_start, col_end, group)
      _G._hls[#_G._hls + 1] = { group = group }
    end
    _G.ui._hl_plugin_entry(entry, 0, hl, 'MiniPackBullet')
  ]])
  local hls = child.lua_get('_G._hls')

  local groups = {}
  for _, h in ipairs(hls) do
    groups[h.group] = true
  end
  MiniTest.expect.equality(groups['MiniPackBulletUpdate'], true)
  MiniTest.expect.equality(groups['MiniPackUpdate'], true)
  child.stop()
end

T['hl_plugin_entry()']['uses pending highlight for cooldown label'] = function()
  local child = make_child()
  child.lua([[
    _G.ui._set_specs({ ['foo.nvim'] = { src = 'https://github.com/org/foo.nvim' } })
    _G.ui._set_git_cache({ ['foo.nvim'] = { org = 'org', repo = 'foo.nvim', branch = 'main', hash = 'abc1234' } })
    _G.ui._set_pending_updates({ ['foo.nvim'] = { kind = 'pending', pending_label = 'available in 3 dias' } })
    local entry = _G.ui._build_plugin_entry('foo.nvim')

    _G._hls = {}
    local function hl(_, _, _, group)
      _G._hls[#_G._hls + 1] = { group = group }
    end
    _G.ui._hl_plugin_entry(entry, 0, hl, 'MiniPackBullet')
  ]])
  local hls = child.lua_get('_G._hls')

  local groups = {}
  for _, h in ipairs(hls) do
    groups[h.group] = true
  end
  MiniTest.expect.equality(groups['MiniPackPending'], true)
  child.stop()
end

-- render_tests_tab (real function) -------------------------------------------

T['render_tests_tab()'] = MiniTest.new_set()

T['render_tests_tab()']['idle state shows run prompt'] = function()
  local child = make_child()
  child.lua([[
    _G.ui._set_test_state('idle')
    _G._lines = {}
    _G.ui._render_tests_tab(_G._lines, function() end)
  ]])
  local lines = child.lua_get('_G._lines')

  local found = false
  for _, l in ipairs(lines) do
    if l:find('Press  r  to run tests', 1, true) then
      found = true
    end
  end
  MiniTest.expect.equality(found, true)
  child.stop()
end

T['render_tests_tab()']['running state shows duck icon'] = function()
  local child = make_child()
  child.lua([[
    _G.ui._set_test_state('running')
    _G._lines = {}
    _G.ui._render_tests_tab(_G._lines, function() end)
  ]])
  local lines = child.lua_get('_G._lines')
  local duck = child.lua_get('_G.icons.misc.duck')

  local found = false
  for _, l in ipairs(lines) do
    if l:find(duck, 1, true) and l:find('Running tests', 1, true) then
      found = true
    end
  end
  MiniTest.expect.equality(found, true)
  child.stop()
end

T['render_tests_tab()']['done state shows stats'] = function()
  local child = make_child()
  child.lua([[
    _G.ui._set_test_state('done')
    _G.ui._set_test_results({
      { desc = { 'tests/test_a.lua', 'foo()', 'works' }, state = 'Pass' },
      { desc = { 'tests/test_a.lua', 'bar()', 'fails' }, state = 'Fail' },
    })
    _G._lines = {}
    _G.ui._render_tests_tab(_G._lines, function() end)
  ]])
  local lines = child.lua_get('_G._lines')

  local found_stats = false
  for _, l in ipairs(lines) do
    if l:find('Total: 2', 1, true) and l:find('Pass: 1', 1, true) and l:find('Fail: 1', 1, true) then
      found_stats = true
    end
  end
  MiniTest.expect.equality(found_stats, true)
  child.stop()
end

T['render_tests_tab()']['groups results by file'] = function()
  local child = make_child()
  child.lua([[
    _G.ui._set_test_state('done')
    _G.ui._set_test_results({
      { desc = { 'tests/test_spec.lua', 'normalize()', 'copies [1]' }, state = 'Pass' },
      { desc = { 'tests/test_spec.lua', 'validate()', 'returns true' }, state = 'Pass' },
      { desc = { 'tests/test_loader.lua', 'is_loaded()', 'returns false' }, state = 'Fail' },
    })
    _G._lines = {}
    _G.ui._render_tests_tab(_G._lines, function() end)
  ]])
  local lines = child.lua_get('_G._lines')

  -- Find file headers
  local spec_idx, loader_idx
  for i, l in ipairs(lines) do
    if l:find('test_spec.lua', 1, true) and not l:find('normalize', 1, true) then
      spec_idx = i
    end
    if l:find('test_loader.lua', 1, true) and not l:find('is_loaded', 1, true) then
      loader_idx = i
    end
  end
  MiniTest.expect.equality(spec_idx ~= nil, true)
  MiniTest.expect.equality(loader_idx ~= nil, true)
  MiniTest.expect.equality(spec_idx < loader_idx, true)
  child.stop()
end

-- on_main_loop (real function) -------------------------------------------------

T['on_main_loop()'] = MiniTest.new_set()

T['on_main_loop()']['schedules callback during fast events'] = function()
  local child = make_child()
  child.lua([[
    local orig_in_fast_event = vim.in_fast_event
    local orig_schedule = vim.schedule

    _G._scheduled = 0
    _G._ran = false

    vim.in_fast_event = function()
      return true
    end

    vim.schedule = function(callback)
      _G._scheduled = _G._scheduled + 1
      callback()
    end

    _G.ui._on_main_loop(function()
      _G._ran = true
    end)

    vim.in_fast_event = orig_in_fast_event
    vim.schedule = orig_schedule
  ]])

  MiniTest.expect.equality(child.lua_get('_G._scheduled'), 1)
  MiniTest.expect.equality(child.lua_get('_G._ran'), true)
  child.stop()
end

-- build_footer (real function) -----------------------------------------------

T['build_footer()'] = MiniTest.new_set()

T['build_footer()']['plugins tab has all action keys'] = function()
  local child = make_child()
  child.lua([[
    _G.ui._set_active_tab('plugins')
    local footer = _G.ui._build_footer()
    _G._keys = {}
    for _, part in ipairs(footer) do
      _G._keys[#_G._keys + 1] = part[1]
    end
    _G._joined = table.concat(_G._keys, '')
  ]])
  local joined = child.lua_get('_G._joined')

  for _, key in ipairs({ 'q', 'o', 'u', 'c', 'x', 'h', 'Tab' }) do
    MiniTest.expect.equality(joined:find(key, 1, true) ~= nil, true)
  end
  child.stop()
end

T['build_footer()']['tests tab has q, r, Tab keys'] = function()
  local child = make_child()
  child.lua([[
    _G.ui._set_active_tab('tests')
    local footer = _G.ui._build_footer()
    _G._keys = {}
    for _, part in ipairs(footer) do
      _G._keys[#_G._keys + 1] = part[1]
    end
    _G._joined = table.concat(_G._keys, '')
  ]])
  local joined = child.lua_get('_G._joined')

  for _, key in ipairs({ 'q', 'r', 'Tab' }) do
    MiniTest.expect.equality(joined:find(key, 1, true) ~= nil, true)
  end
  child.stop()
end

return T
