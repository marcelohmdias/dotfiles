-- LSP layer: buffer-local keymaps registered on LspAttach.
-- This module must be require-safe (no side-effects); call setup() to activate.

local M = {}

--- Check if any attached LSP client supports a given method.
-- `clients` is injectable for testing; defaults to vim.lsp.get_clients.
---@param method string LSP method (e.g. 'textDocument/codeAction')
---@param bufnr number
---@param clients? fun(opts: table): table[]
---@return boolean
function M._has_method(method, bufnr, clients)
  clients = clients or vim.lsp.get_clients
  for _, client in ipairs(clients({ bufnr = bufnr })) do
    if client:supports_method(method, bufnr) then
      return true
    end
  end
  return false
end

--- Set buffer-local keymap only if LSP method is supported.
-- `clients` is injectable for testing.
---@param method string|string[] LSP method(s) to check
---@param mode string|string[]
---@param lhs string
---@param rhs string|function
---@param opts vim.keymap.set.Opts
---@param bufnr number
---@param clients? fun(opts: table): table[]
function M._lsp_map(method, mode, lhs, rhs, opts, bufnr, clients)
  local methods = type(method) == 'string' and { method } or method
  for _, m in ipairs(methods) do
    if M._has_method(m, bufnr, clients) then
      opts.buffer = bufnr
      vim.keymap.set(mode, lhs, rhs, opts)
      return
    end
  end
end

---@param buf number
local function info_map(buf)
  M._lsp_map('textDocument/hover', 'n', '<leader>cl', function()
    Snacks.picker.lsp_config()
  end, { desc = 'Lsp Info' }, buf)
end

---@param buf number
local function goto_maps(buf)
  M._lsp_map('textDocument/definition', 'n', 'gd', function()
    Snacks.picker.lsp_definitions()
  end, { desc = 'Goto Definition' }, buf)
  M._lsp_map('textDocument/declaration', 'n', 'gD', function()
    Snacks.picker.lsp_declarations()
  end, { desc = 'Goto Declaration' }, buf)
  M._lsp_map('textDocument/references', 'n', 'gr', function()
    Snacks.picker.lsp_references()
  end, { desc = 'Goto References', nowait = true }, buf)
  M._lsp_map('textDocument/implementation', 'n', 'gI', function()
    Snacks.picker.lsp_implementations()
  end, { desc = 'Goto Implementations' }, buf)
  M._lsp_map('textDocument/typeDefinition', 'n', 'gy', function()
    Snacks.picker.lsp_type_definitions()
  end, { desc = 'Goto Type Definition' }, buf)
  M._lsp_map('callHierarchy/incomingCalls', 'n', 'gai', function()
    Snacks.picker.lsp_incoming_calls()
  end, { desc = 'Goto Incoming Calls' }, buf)
  M._lsp_map('callHierarchy/outgoingCalls', 'n', 'gao', function()
    Snacks.picker.lsp_outgoing_calls()
  end, { desc = 'Goto Outgoing Calls' }, buf)
end

---@param buf number
local function signature_maps(buf)
  M._lsp_map('textDocument/signatureHelp', 'n', '<leader>ck', function()
    return vim.lsp.buf.signature_help()
  end, { desc = 'Signature Help' }, buf)
  M._lsp_map('textDocument/signatureHelp', 'i', '<C-k>', function()
    return vim.lsp.buf.signature_help()
  end, { desc = 'Signature Help' }, buf)
end

---@param buf number
local function code_action_maps(buf)
  M._lsp_map('textDocument/codeAction', { 'n', 'x' }, '<leader>ca', function()
    require('actions-preview').code_actions()
  end, { desc = 'Code Action (Preview)' }, buf)
  M._lsp_map('textDocument/codeAction', 'n', '<leader>cA', function()
    vim.lsp.buf.code_action({ context = { only = { 'source' }, diagnostics = {} } })
  end, { desc = 'Source Action' }, buf)
end

---@param buf number
local function source_action_maps(buf)
  M._lsp_map('textDocument/codeAction', 'n', '<leader>co', function()
    vim.lsp.buf.code_action({ context = { only = { 'source.organizeImports' }, diagnostics = {} } })
  end, { desc = 'Organize Imports' }, buf)
end

---@param buf number
local function rename_maps(buf)
  M._lsp_map('textDocument/rename', 'n', '<leader>cr', function()
    local ok, inc_rename = pcall(require, 'inc_rename')
    if ok then
      vim.api.nvim_feedkeys(':' .. inc_rename.config.cmd_name .. ' ' .. vim.fn.expand('<cword>'), 'n', false)
      return
    end
    vim.lsp.buf.rename()
  end, { desc = 'Rename (inc-rename.nvim)' }, buf)
  M._lsp_map({ 'workspace/didRenameFiles', 'workspace/willRenameFiles' }, 'n', '<leader>cR', function()
    Snacks.rename.rename_file()
  end, { desc = 'Rename File' }, buf)
end

---@param buf number
local function symbol_maps(buf)
  M._lsp_map('textDocument/documentSymbol', 'n', '<leader>ss', function()
    Snacks.picker.lsp_symbols()
  end, { desc = 'LSP Symbols' }, buf)
  M._lsp_map('workspace/symbol', 'n', '<leader>sS', function()
    Snacks.picker.lsp_workspace_symbols()
  end, { desc = 'LSP Workspace Symbols' }, buf)
  M._lsp_map('workspace/diagnostic', 'n', '<leader>sD', function()
    vim.lsp.buf.workspace_diagnostics()
  end, { desc = 'Workspace Diagnostics' }, buf)
end

---@param buf number
local function codelens_maps(buf)
  M._lsp_map('textDocument/codeLens', 'n', '<leader>cc', vim.lsp.codelens.run, { desc = 'Run Codelens' }, buf)
  M._lsp_map('textDocument/codeLens', { 'n', 'x' }, '<leader>cC', function()
    vim.lsp.codelens.refresh()
    vim.lsp.codelens.display()
  end, { desc = 'Refresh Codelens' }, buf)
  if M._has_method('textDocument/codeLens', buf) then
    vim.lsp.codelens.enable(true, { bufnr = buf })
  end
end

---@param buf number
local function reference_maps(buf)
  if vim.g.snacks_words_enabled ~= false then
    M._lsp_map('textDocument/documentHighlight', 'n', ']]', function()
      Snacks.words.jump(vim.v.count1)
    end, { desc = 'Next Reference' }, buf)
    M._lsp_map('textDocument/documentHighlight', 'n', '[[', function()
      Snacks.words.jump(-vim.v.count1)
    end, { desc = 'Prev Reference' }, buf)
    M._lsp_map('textDocument/documentHighlight', 'n', '<a-n>', function()
      Snacks.words.jump(vim.v.count1, true)
    end, { desc = 'Next Reference' }, buf)
    M._lsp_map('textDocument/documentHighlight', 'n', '<a-p>', function()
      Snacks.words.jump(-vim.v.count1, true)
    end, { desc = 'Prev Reference' }, buf)
  end
end

--- Activate LspAttach keymaps.
function M.setup()
  autocmd('LspAttach', {
    callback = function(ev)
      local buf = ev.buf
      info_map(buf)
      goto_maps(buf)
      signature_maps(buf)
      code_action_maps(buf)
      source_action_maps(buf)
      rename_maps(buf)
      symbol_maps(buf)
      codelens_maps(buf)
      reference_maps(buf)
    end,
  })
end

return M
