local M = {}

--- Create autocmd with default MiniPack augroup.
---@param event string|string[] Autocmd event(s)
---@param opts vim.api.keyset.create_autocmd Autocmd options (group defaults to MiniPack)
local _augroup
function M.autocmd(event, opts)
  _augroup = _augroup or vim.api.nvim_create_augroup('MiniPack', { clear = false })
  opts = vim.tbl_extend('force', { group = _augroup }, opts or {})
  vim.api.nvim_create_autocmd(event, opts)
end

--- Return a closure that executes a Vim command.
---@param c string Vim command to execute
---@return fun() closure Function that runs the command when called
function M.cmd(c)
  return function()
    vim.cmd(c)
  end
end

--- Safe keymap set (based on LazyVim safe_keymap_set).
--- Filters modes where MiniPack key stub exists to avoid overwriting lazy-load triggers.
---@param mode string|string[] Vim mode(s) for the mapping
---@param lhs string Left-hand side of the mapping
---@param rhs string|fun() Right-hand side of the mapping
---@param opts? vim.keymap.set.Opts Keymap options (silent defaults to true)
function M.map(mode, lhs, rhs, opts)
  local modes = type(mode) == 'string' and { mode } or mode

  local loader = package.loaded['core.pkg.loader']
  if loader and loader.has_key then
    modes = vim.tbl_filter(function(m)
      return not loader.has_key(lhs, m)
    end, modes)
  end

  if #modes > 0 then
    opts = opts or {}
    opts.silent = opts.silent ~= false
    if opts.remap and vim.g.vscode then
      opts.remap = nil
    end
    vim.keymap.set(modes, lhs, rhs, opts)
  end
end

return M
