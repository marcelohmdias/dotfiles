---@diagnostic disable: undefined-global
local H = require('tests.helpers')

local T = MiniTest.new_set()

-- statuscolumn / formatexpr --

T['statuscolumn()'] = MiniTest.new_set()

T['statuscolumn()']['returns empty string when snacks not loaded'] = function()
  local child = H.new_child()
  local r = child.lua_get([[require('core.utils').statuscolumn()]])
  MiniTest.expect.equality(r, '')
  child.stop()
end

T['formatexpr()'] = MiniTest.new_set()

T['formatexpr()']['falls back to lsp formatexpr'] = function()
  local child = H.new_child()
  -- conform not loaded, so should call vim.lsp.formatexpr
  local r = child.lua_get([[type(require('core.utils').formatexpr())]])
  -- vim.lsp.formatexpr returns a number (0)
  MiniTest.expect.equality(r, 'number')
  child.stop()
end

-- root_realpath --

T['root_realpath()'] = MiniTest.new_set()

T['root_realpath()']['returns nil for nil input'] = function()
  local child = H.new_child()
  MiniTest.expect.equality(child.lua_get([[require('core.utils').root_realpath(nil)]]), vim.NIL)
  child.stop()
end

T['root_realpath()']['returns nil for empty string'] = function()
  local child = H.new_child()
  MiniTest.expect.equality(child.lua_get([[require('core.utils').root_realpath('')]]), vim.NIL)
  child.stop()
end

T['root_realpath()']['normalizes backslashes'] = function()
  local child = H.new_child()
  child.lua([[_G._r = require('core.utils').root_realpath('/tmp')]])
  local r = child.lua_get('_G._r')
  -- Should not contain backslashes
  MiniTest.expect.equality(r:find('\\'), nil)
  child.stop()
end

-- root_bufpath --

T['root_bufpath()'] = MiniTest.new_set()

T['root_bufpath()']['returns path for buffer with name'] = function()
  local child = H.new_child()
  child.lua([[
    vim.api.nvim_buf_set_name(0, '/tmp/test_file.lua')
    _G._bp = require('core.utils').root_bufpath(0)
  ]])
  local r = child.lua_get('_G._bp')
  -- Should contain test_file.lua (path may be resolved via realpath)
  MiniTest.expect.equality(type(r), 'string')
  child.stop()
end

-- root (pattern detector) --

T['root()'] = MiniTest.new_set()

T['root()']['returns cwd as fallback'] = function()
  local child = H.new_child()
  child.lua([[
    local utils = require('core.utils')
    -- Use spec with no matches to force cwd fallback
    _G._root = utils.root()
  ]])
  local root = child.lua_get('_G._root')
  local cwd = child.lua_get('vim.uv.cwd()')
  MiniTest.expect.equality(root, cwd)
  child.stop()
end

T['root()']['detects pattern-based root'] = function()
  local child = H.new_child()
  child.lua([[
    local utils = require('core.utils')
    -- Create a temp dir with .git marker
    _G._tmpdir = vim.fn.tempname()
    vim.fn.mkdir(_G._tmpdir .. '/sub', 'p')
    local f = io.open(_G._tmpdir .. '/.git', 'w'); f:write(''); f:close()
    -- Set buffer to a file inside the dir
    vim.api.nvim_buf_set_name(0, _G._tmpdir .. '/sub/test.lua')
    _G._root = utils.root({ buf = 0 })
  ]])
  local root = child.lua_get('_G._root')
  local tmpdir = child.lua_get('_G._tmpdir')
  -- root should resolve to tmpdir (where .git is)
  local expected = child.lua_get('require("core.utils").root_realpath(_G._tmpdir)')
  MiniTest.expect.equality(root, expected)

  child.lua([[vim.fn.delete(_G._tmpdir, 'rf')]])
  child.stop()
end

T['root()']['caches result per buffer'] = function()
  local child = H.new_child()
  child.lua([[
    local utils = require('core.utils')
    _G._r1 = utils.root()
    _G._r2 = utils.root()
  ]])
  MiniTest.expect.equality(child.lua_get('_G._r1'), child.lua_get('_G._r2'))
  child.stop()
end

-- root_git --

T['root_git()'] = MiniTest.new_set()

T['root_git()']['finds git root'] = function()
  local child = H.new_child()
  child.lua([[
    local utils = require('core.utils')
    _G._tmpdir = vim.fn.tempname()
    vim.fn.mkdir(_G._tmpdir .. '/sub', 'p')
    vim.fn.mkdir(_G._tmpdir .. '/.git', 'p')
    vim.api.nvim_buf_set_name(0, _G._tmpdir .. '/sub/file.lua')
    _G._git = utils.root_git()
  ]])
  local git_root = child.lua_get('_G._git')
  local expected = child.lua_get('require("core.utils").root_realpath(_G._tmpdir)')
  MiniTest.expect.equality(git_root, expected)

  child.lua([[vim.fn.delete(_G._tmpdir, 'rf')]])
  child.stop()
end

-- root_setup --

T['root_setup()'] = MiniTest.new_set()

T['root_setup()']['creates cache invalidation autocmds'] = function()
  local child = H.new_child()
  child.lua([[require('core.utils').root_setup()]])
  child.lua([[_G._aus = vim.api.nvim_get_autocmds({ group = 'MiniPack_root_cache' })]])
  -- Should have autocmds for LspAttach, BufWritePost, DirChanged, BufEnter
  MiniTest.expect.equality(child.lua_get('#_G._aus >= 4'), true)
  child.stop()
end

-- conflict_setup_hl --

T['conflict_setup_hl()'] = MiniTest.new_set()

T['conflict_setup_hl()']['creates highlight groups'] = function()
  local child = H.new_child()
  child.lua([[
    -- Mock catppuccin palette
    package.preload['catppuccin.palettes'] = function()
      return {
        get_palette = function()
          return { green = '#a6e3a1', blue = '#89b4fa', mauve = '#cba6f7' }
        end,
      }
    end
    require('core.utils').conflict_setup_hl()
  ]])
  local groups = { 'GitConflictCurrent', 'GitConflictCurrentLabel', 'GitConflictIncoming', 'GitConflictIncomingLabel', 'GitConflictAncestor', 'GitConflictAncestorLabel' }
  for _, group in ipairs(groups) do
    local hl = child.lua_get(string.format([[vim.api.nvim_get_hl(0, { name = '%s' })]], group))
    MiniTest.expect.equality(hl.bg ~= nil, true)
  end
  child.stop()
end

-- conflict_apply --

T['conflict_apply()'] = MiniTest.new_set()

T['conflict_apply()']['highlights conflict markers'] = function()
  local child = H.new_child()
  child.lua([[
    package.preload['catppuccin.palettes'] = function()
      return {
        get_palette = function()
          return { green = '#a6e3a1', blue = '#89b4fa', mauve = '#cba6f7' }
        end,
      }
    end
    local utils = require('core.utils')
    utils.conflict_setup_hl()
    vim.api.nvim_buf_set_lines(0, 0, -1, false, {
      '<<<<<<< HEAD',
      'our line',
      '=======',
      'their line',
      '>>>>>>> branch',
    })
    utils.conflict_apply(0)
    _G._ns = vim.api.nvim_create_namespace('git_conflict')
    _G._marks = vim.api.nvim_buf_get_extmarks(0, _G._ns, 0, -1, { details = true })
  ]])
  local marks = child.lua_get('#_G._marks')
  MiniTest.expect.equality(marks, 5)
  child.stop()
end

T['conflict_apply()']['skips buffer without conflict markers'] = function()
  local child = H.new_child()
  child.lua([[
    package.preload['catppuccin.palettes'] = function()
      return {
        get_palette = function()
          return { green = '#a6e3a1', blue = '#89b4fa', mauve = '#cba6f7' }
        end,
      }
    end
    local utils = require('core.utils')
    utils.conflict_setup_hl()
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { 'normal line', 'another line' })
    utils.conflict_apply(0)
    _G._ns = vim.api.nvim_create_namespace('git_conflict')
    _G._marks = vim.api.nvim_buf_get_extmarks(0, _G._ns, 0, -1, {})
  ]])
  local marks = child.lua_get('#_G._marks')
  MiniTest.expect.equality(marks, 0)
  child.stop()
end

T['conflict_apply()']['skips bigfile buffers'] = function()
  local child = H.new_child()
  child.lua([[
    package.preload['catppuccin.palettes'] = function()
      return {
        get_palette = function()
          return { green = '#a6e3a1', blue = '#89b4fa', mauve = '#cba6f7' }
        end,
      }
    end
    local utils = require('core.utils')
    utils.conflict_setup_hl()
    vim.api.nvim_buf_set_lines(0, 0, -1, false, {
      '<<<<<<< HEAD',
      'our line',
      '=======',
      'their line',
      '>>>>>>> branch',
    })
    vim.b[0].snacks_bigfile = true
    utils.conflict_apply(0)
    _G._ns = vim.api.nvim_create_namespace('git_conflict')
    _G._marks = vim.api.nvim_buf_get_extmarks(0, _G._ns, 0, -1, {})
  ]])
  local marks = child.lua_get('#_G._marks')
  MiniTest.expect.equality(marks, 0)
  child.stop()
end

T['conflict_apply()']['handles 3-way conflict with ancestor'] = function()
  local child = H.new_child()
  child.lua([[
    package.preload['catppuccin.palettes'] = function()
      return {
        get_palette = function()
          return { green = '#a6e3a1', blue = '#89b4fa', mauve = '#cba6f7' }
        end,
      }
    end
    local utils = require('core.utils')
    utils.conflict_setup_hl()
    vim.api.nvim_buf_set_lines(0, 0, -1, false, {
      '<<<<<<< HEAD',
      'our line',
      '||||||| merged common ancestors',
      'ancestor line',
      '=======',
      'their line',
      '>>>>>>> branch',
    })
    utils.conflict_apply(0)
    _G._ns = vim.api.nvim_create_namespace('git_conflict')
    _G._marks = vim.api.nvim_buf_get_extmarks(0, _G._ns, 0, -1, { details = true })
  ]])
  local marks = child.lua_get('#_G._marks')
  MiniTest.expect.equality(marks, 7)
  child.stop()
end

T['conflict_apply()']['clears previous highlights on re-apply'] = function()
  local child = H.new_child()
  child.lua([[
    package.preload['catppuccin.palettes'] = function()
      return {
        get_palette = function()
          return { green = '#a6e3a1', blue = '#89b4fa', mauve = '#cba6f7', base = '#1e1e2e' }
        end,
      }
    end
    local utils = require('core.utils')
    utils.conflict_setup_hl()
    vim.api.nvim_buf_set_lines(0, 0, -1, false, {
      '<<<<<<< HEAD',
      'our line',
      '=======',
      'their line',
      '>>>>>>> branch',
    })
    utils.conflict_apply(0)
    -- Remove conflict, re-apply
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { 'resolved line' })
    utils.conflict_apply(0)
    _G._ns = vim.api.nvim_create_namespace('git_conflict')
    _G._marks = vim.api.nvim_buf_get_extmarks(0, _G._ns, 0, -1, {})
  ]])
  local marks = child.lua_get('#_G._marks')
  MiniTest.expect.equality(marks, 0)
  child.stop()
end

T['conflict_apply()']['handles multiple conflicts in same buffer'] = function()
  local child = H.new_child()
  child.lua([[
    package.preload['catppuccin.palettes'] = function()
      return {
        get_palette = function()
          return { green = '#a6e3a1', blue = '#89b4fa', mauve = '#cba6f7', base = '#1e1e2e' }
        end,
      }
    end
    local utils = require('core.utils')
    utils.conflict_setup_hl()
    vim.api.nvim_buf_set_lines(0, 0, -1, false, {
      '<<<<<<< HEAD',
      'our first',
      '=======',
      'their first',
      '>>>>>>> branch-a',
      'clean line between conflicts',
      '<<<<<<< HEAD',
      'our second',
      '=======',
      'their second',
      '>>>>>>> branch-b',
    })
    utils.conflict_apply(0)
    _G._ns = vim.api.nvim_create_namespace('git_conflict')
    _G._marks = vim.api.nvim_buf_get_extmarks(0, _G._ns, 0, -1, { details = true })
  ]])
  -- 2 conflicts x 5 lines each = 10, clean line between = 0 highlight
  local marks = child.lua_get('#_G._marks')
  MiniTest.expect.equality(marks, 10)
  child.stop()
end

T['conflict_apply()']['no highlights on normal code file'] = function()
  local child = H.new_child()
  child.lua([[
    package.preload['catppuccin.palettes'] = function()
      return {
        get_palette = function()
          return { green = '#a6e3a1', blue = '#89b4fa', mauve = '#cba6f7', base = '#1e1e2e' }
        end,
      }
    end
    local utils = require('core.utils')
    utils.conflict_setup_hl()
    local lines = {}
    for i = 1, 100 do
      lines[i] = 'local x_' .. i .. ' = ' .. i
    end
    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
    utils.conflict_apply(0)
    _G._ns = vim.api.nvim_create_namespace('git_conflict')
    _G._marks = vim.api.nvim_buf_get_extmarks(0, _G._ns, 0, -1, {})
  ]])
  local marks = child.lua_get('#_G._marks')
  MiniTest.expect.equality(marks, 0)
  child.stop()
end

T['conflict_apply()']['skips large files by size'] = function()
  local child = H.new_child()
  child.lua([[
    package.preload['catppuccin.palettes'] = function()
      return {
        get_palette = function()
          return { green = '#a6e3a1', blue = '#89b4fa', mauve = '#cba6f7', base = '#1e1e2e' }
        end,
      }
    end
    local utils = require('core.utils')
    utils.conflict_setup_hl()

    -- Create a temp file larger than 1.5MB
    _G._tmpfile = vim.fn.tempname()
    local f = io.open(_G._tmpfile, 'w')
    f:write('<<<<<<< HEAD\n')
    f:write(string.rep('x', 1.6 * 1024 * 1024))
    f:write('\n=======\ntheirs\n>>>>>>> branch\n')
    f:close()

    vim.cmd('edit ' .. _G._tmpfile)
    utils.conflict_apply(0)
    _G._ns = vim.api.nvim_create_namespace('git_conflict')
    _G._marks = vim.api.nvim_buf_get_extmarks(0, _G._ns, 0, -1, {})
  ]])
  local marks = child.lua_get('#_G._marks')
  MiniTest.expect.equality(marks, 0)
  child.lua([[vim.fn.delete(_G._tmpfile)]])
  child.stop()
end

T['conflict_apply()']['handles medium file with conflict at end'] = function()
  local child = H.new_child()
  child.lua([[
    package.preload['catppuccin.palettes'] = function()
      return {
        get_palette = function()
          return { green = '#a6e3a1', blue = '#89b4fa', mauve = '#cba6f7', base = '#1e1e2e' }
        end,
      }
    end
    local utils = require('core.utils')
    utils.conflict_setup_hl()
    local lines = {}
    for i = 1, 1000 do
      lines[i] = '-- line ' .. i
    end
    lines[1001] = '<<<<<<< HEAD'
    lines[1002] = 'ours'
    lines[1003] = '======='
    lines[1004] = 'theirs'
    lines[1005] = '>>>>>>> branch'
    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
    utils.conflict_apply(0)
    _G._ns = vim.api.nvim_create_namespace('git_conflict')
    _G._marks = vim.api.nvim_buf_get_extmarks(0, _G._ns, 0, -1, {})
  ]])
  local marks = child.lua_get('#_G._marks')
  MiniTest.expect.equality(marks, 5)
  child.stop()
end

T['conflict_apply()']['skips invalid buffer'] = function()
  local child = H.new_child()
  child.lua([[
    package.preload['catppuccin.palettes'] = function()
      return {
        get_palette = function()
          return { green = '#a6e3a1', blue = '#89b4fa', mauve = '#cba6f7', base = '#1e1e2e' }
        end,
      }
    end
    local utils = require('core.utils')
    utils.conflict_setup_hl()
    -- Buffer 9999 doesn't exist
    _G._ok = pcall(utils.conflict_apply, 9999)
  ]])
  local ok = child.lua_get('_G._ok')
  MiniTest.expect.equality(ok, true)
  child.stop()
end

return T
