---@diagnostic disable: undefined-global
local H = require('tests.helpers')

local child = H.new_child()

local T = MiniTest.new_set({
  hooks = {
    pre_once = function()
      child.lua([[vim.g.mapleader = ' ']])
    end,
    post_once = function()
      child.stop()
    end,
  },
})

-- autocmd() --

T['autocmd()'] = MiniTest.new_set()

T['autocmd()']['creates autocmd in MiniPack group'] = function()
  child.lua([[require('core.mappers').autocmd('BufRead', { pattern = '*.test', callback = function() end })]])
  child.lua([[_G._aus = vim.api.nvim_get_autocmds({ group = 'MiniPack', event = 'BufRead' })]])
  MiniTest.expect.equality(child.lua_get('#_G._aus > 0'), true)
  MiniTest.expect.equality(child.lua_get('_G._aus[1].pattern'), '*.test')
end

T['autocmd()']['uses MiniPack group by default'] = function()
  child.lua([[require('core.mappers').autocmd('BufWrite', { pattern = '*', callback = function() end })]])
  child.lua([[_G._aus = vim.api.nvim_get_autocmds({ group = 'MiniPack', event = 'BufWrite' })]])
  MiniTest.expect.equality(child.lua_get('#_G._aus > 0'), true)
  MiniTest.expect.equality(child.lua_get('_G._aus[1].group_name'), 'MiniPack')
end

-- cmd() --

T['cmd()'] = MiniTest.new_set()

T['cmd()']['returns a callable function'] = function()
  child.lua([[_G._t = type(require('core.mappers').cmd('echo "hi"'))]])
  MiniTest.expect.equality(child.lua_get('_G._t'), 'function')
end

T['cmd()']['executes the vim command'] = function()
  child.lua([[
    local fn = require('core.mappers').cmd('let g:_test_cmd = 42')
    fn()
  ]])
  MiniTest.expect.equality(child.lua_get('vim.g._test_cmd'), 42)
end

-- map() --

T['map()'] = MiniTest.new_set()

T['map()']['creates a keymap'] = function()
  child.lua([[require('core.mappers').map('n', 'gz', ':echo "test"<CR>')]])
  child.lua([[
    _G._found = false
    for _, m in ipairs(vim.api.nvim_get_keymap('n')) do
      if m.lhs == 'gz' then _G._found = true; break end
    end
  ]])
  MiniTest.expect.equality(child.lua_get('_G._found'), true)
end

T['map()']['defaults silent to true'] = function()
  child.lua([[require('core.mappers').map('n', 'gy', ':echo "silent"<CR>')]])
  child.lua([[
    _G._silent = nil
    for _, m in ipairs(vim.api.nvim_get_keymap('n')) do
      if m.lhs == 'gy' then _G._silent = m.silent; break end
    end
  ]])
  MiniTest.expect.equality(child.lua_get('_G._silent'), 1)
end

T['map()']['respects silent = false'] = function()
  child.lua([[require('core.mappers').map('n', 'gx', ':echo "loud"<CR>', { silent = false })]])
  child.lua([[
    _G._silent = nil
    for _, m in ipairs(vim.api.nvim_get_keymap('n')) do
      if m.lhs == 'gx' then _G._silent = m.silent; break end
    end
  ]])
  MiniTest.expect.equality(child.lua_get('_G._silent'), 0)
end

T['map()']['accepts multiple modes'] = function()
  child.lua([[require('core.mappers').map({ 'n', 'v' }, 'gw', ':echo "multi"<CR>')]])
  child.lua([[
    _G._n = false
    for _, m in ipairs(vim.api.nvim_get_keymap('n')) do
      if m.lhs == 'gw' then _G._n = true; break end
    end
    _G._v = false
    for _, m in ipairs(vim.api.nvim_get_keymap('v')) do
      if m.lhs == 'gw' then _G._v = true; break end
    end
  ]])
  MiniTest.expect.equality(child.lua_get('_G._n'), true)
  MiniTest.expect.equality(child.lua_get('_G._v'), true)
end

T['map()']['preserves remap outside vscode'] = function()
  child.lua([[
    vim.g.vscode = nil
    require('core.mappers').map('n', 'gr1', 'j', { remap = true })
  ]])
  child.lua([[
    _G._noremap = nil
    for _, m in ipairs(vim.api.nvim_get_keymap('n')) do
      if m.lhs == 'gr1' then _G._noremap = m.noremap; break end
    end
  ]])
  MiniTest.expect.equality(child.lua_get('_G._noremap'), 0)
end

T['map()']['strips remap inside vscode'] = function()
  child.lua([[
    vim.g.vscode = true
    require('core.mappers').map('n', 'gr2', 'j', { remap = true })
    vim.g.vscode = nil
  ]])
  child.lua([[
    _G._noremap = nil
    for _, m in ipairs(vim.api.nvim_get_keymap('n')) do
      if m.lhs == 'gr2' then _G._noremap = m.noremap; break end
    end
  ]])
  MiniTest.expect.equality(child.lua_get('_G._noremap'), 1)
end

T['map()']['filters modes with has_key stub'] = function()
  child.lua([[
    package.loaded['core.pkg.loader'] = {
      has_key = function(lhs, mode)
        return lhs == 'gq' and mode == 'n'
      end,
    }
    require('core.mappers').map({ 'n', 'v' }, 'gq', ':echo "filtered"<CR>')
  ]])
  child.lua([[
    _G._n = false
    for _, m in ipairs(vim.api.nvim_get_keymap('n')) do
      if m.lhs == 'gq' then _G._n = true; break end
    end
    _G._v = false
    for _, m in ipairs(vim.api.nvim_get_keymap('v')) do
      if m.lhs == 'gq' then _G._v = true; break end
    end
  ]])
  MiniTest.expect.equality(child.lua_get('_G._n'), false)
  MiniTest.expect.equality(child.lua_get('_G._v'), true)
end

return T
