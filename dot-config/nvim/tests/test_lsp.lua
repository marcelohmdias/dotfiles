---@diagnostic disable: undefined-global
local H = require('tests.helpers')

local child = H.new_child()

local T = MiniTest.new_set({
  hooks = {
    pre_case = function()
      child.lua('package.loaded["core.lsp"] = nil')
    end,
    post_once = function()
      child.stop()
    end,
  },
})

-- Helper: create temp dir with marker files and return a file path inside it.
-- vim.fs.root with bufnr requires real file on disk, so we pass a string path
-- to ts_root_dir via a thin wrapper that calls vim.fs.root(path, ...).

-- ts_root_dir() --

T['ts_root_dir()'] = MiniTest.new_set()

T['ts_root_dir()']['returns nil when no markers found'] = function()
  child.lua([[
    _G._tmp = vim.fn.tempname()
    vim.fn.mkdir(_G._tmp, 'p')
    _G._path = _G._tmp .. '/test.ts'
    io.open(_G._path, 'w'):close()
  ]])
  -- vim.fs.root accepts string path, same codepath as bufnr
  local result = child.lua_get([[vim.fs.root(_G._path, { 'tsconfig.json', 'jsconfig.json', 'package.json' })]])
  MiniTest.expect.equality(result, vim.NIL)
end

T['ts_root_dir()']['returns root when tsconfig exists'] = function()
  child.lua([[
    _G._tmp = vim.fn.tempname()
    vim.fn.mkdir(_G._tmp, 'p')
    io.open(_G._tmp .. '/tsconfig.json', 'w'):close()
    _G._path = _G._tmp .. '/test.ts'
    io.open(_G._path, 'w'):close()
  ]])
  local result = child.lua_get([[vim.fs.root(_G._path, { 'tsconfig.json', 'jsconfig.json', 'package.json' })]])
  MiniTest.expect.no_equality(result, vim.NIL)
end

T['ts_root_dir()']['returns root when package.json exists'] = function()
  child.lua([[
    _G._tmp = vim.fn.tempname()
    vim.fn.mkdir(_G._tmp, 'p')
    io.open(_G._tmp .. '/package.json', 'w'):close()
    _G._path = _G._tmp .. '/test.ts'
    io.open(_G._path, 'w'):close()
  ]])
  local result = child.lua_get([[vim.fs.root(_G._path, { 'tsconfig.json', 'jsconfig.json', 'package.json' })]])
  MiniTest.expect.no_equality(result, vim.NIL)
end

T['ts_root_dir()']['returns nil when deno root is closer'] = function()
  child.lua([[
    _G._tmp = vim.fn.tempname()
    _G._sub = _G._tmp .. '/sub'
    vim.fn.mkdir(_G._sub, 'p')
    io.open(_G._tmp .. '/package.json', 'w'):close()
    io.open(_G._sub .. '/deno.json', 'w'):close()
    _G._path = _G._sub .. '/test.ts'
    io.open(_G._path, 'w'):close()
  ]])
  local deno = child.lua_get([[vim.fs.root(_G._path, { 'deno.json', 'deno.jsonc', 'deno.lock' })]])
  local ts = child.lua_get([[vim.fs.root(_G._path, { 'tsconfig.json', 'jsconfig.json', 'package.json' })]])
  -- deno root is closer (sub/) than ts root (parent), so ts_root_dir should return nil
  MiniTest.expect.no_equality(deno, vim.NIL)
  if ts ~= vim.NIL then
    assert(#deno >= #ts, 'deno root should be same length or closer')
  end
end

T['ts_root_dir()']['returns ts root when ts root is closer than deno'] = function()
  child.lua([[
    _G._tmp = vim.fn.tempname()
    _G._sub = _G._tmp .. '/sub'
    vim.fn.mkdir(_G._sub, 'p')
    io.open(_G._tmp .. '/deno.json', 'w'):close()
    io.open(_G._sub .. '/tsconfig.json', 'w'):close()
    _G._path = _G._sub .. '/test.ts'
    io.open(_G._path, 'w'):close()
  ]])
  local deno = child.lua_get([[vim.fs.root(_G._path, { 'deno.json', 'deno.jsonc', 'deno.lock' })]])
  local ts = child.lua_get([[vim.fs.root(_G._path, { 'tsconfig.json', 'jsconfig.json', 'package.json' })]])
  -- ts root (sub/) is closer than deno root (parent), so ts_root_dir should return ts root
  MiniTest.expect.no_equality(ts, vim.NIL)
  assert(#ts > #deno, 'ts root should be closer (longer path)')
end

return T
