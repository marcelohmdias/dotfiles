-- LSP server enablement and keymaps
-- Neovim 0.12 native LSP: configs in lsp/ dir, enabled via vim.lsp.enable()
-- Keymaps are buffer-local, set on LspAttach per client capabilities

--- Check if any file from a list exists in the project root or ancestors.
---@param markers string[]
---@return boolean
local function has_config(markers)
  return vim.fs.root(0, markers) ~= nil
end

--- Check if any attached LSP client supports a given method.
---@param method string LSP method (e.g. 'textDocument/codeAction')
---@param bufnr number
---@return boolean
local function has_method(method, bufnr)
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
    if client:supports_method(method, bufnr) then
      return true
    end
  end
  return false
end

--- Set buffer-local keymap only if LSP method is supported.
---@param method string|string[] LSP method(s) to check
---@param mode string|string[]
---@param lhs string
---@param rhs string|function
---@param opts vim.keymap.set.Opts
---@param bufnr number
local function lsp_map(method, mode, lhs, rhs, opts, bufnr)
  local methods = type(method) == 'string' and { method } or method
  for _, m in ipairs(methods) do
    if has_method(m, bufnr) then
      opts.buffer = bufnr
      vim.keymap.set(mode, lhs, rhs, opts)
      return
    end
  end
end

-- LSP keymaps (buffer-local, set on attach) ----------------------------------
-- Based on LazyVim lsp/init.lua servers['*'].keys

autocmd('LspAttach', {
  callback = function(ev)
    local buf = ev.buf

    -- Info
    lsp_map('textDocument/hover', 'n', '<leader>cl', function() Snacks.picker.lsp_config() end, { desc = 'Lsp Info' }, buf)

    -- Go to
    lsp_map('textDocument/definition', 'n', 'gd', function() Snacks.picker.lsp_definitions() end, { desc = 'Goto Definition' }, buf)
    lsp_map('textDocument/declaration', 'n', 'gD', function () Snacks.picker.lsp_declarations() end, { desc = 'Goto Declaration' }, buf)
    lsp_map('textDocument/references', 'n', 'gr', function () Snacks.picker.lsp_references() end, { desc = 'Goto References', nowait = true }, buf)
    lsp_map('textDocument/implementation', 'n', 'gI', function () Snacks.picker.lsp_implementations() end, { desc = 'Goto Implementations' }, buf)
    lsp_map('textDocument/typeDefinition', 'n', 'gy', function () Snacks.picker.lsp_type_definitions() end, { desc = 'Goto Type Definition' }, buf)

    -- Signature Help (insert mode handled by blink.cmp via <c-k>)
    lsp_map('textDocument/signatureHelp', 'n', '<leader>ck', function()
      return vim.lsp.buf.signature_help()
    end, { desc = 'Signature Help' }, buf)

    -- Code actions
    lsp_map('textDocument/codeAction', { 'n', 'x' }, '<leader>ca', function()
      require('actions-preview').code_actions()
    end, { desc = 'Code Action (Preview)' }, buf)
    lsp_map('textDocument/codeAction', 'n', '<leader>cA', function()
      vim.lsp.buf.code_action({ context = { only = { 'source' }, diagnostics = {} } })
    end, { desc = 'Source Action' }, buf)

    -- Rename
    lsp_map('textDocument/rename', 'n', '<leader>cr', function()
      local ok, inc_rename = pcall(require, 'inc_rename')
      if ok then
        vim.api.nvim_feedkeys(':' .. inc_rename.config.cmd_name .. ' ' .. vim.fn.expand('<cword>'), 'n', false)
        return
      end
      vim.lsp.buf.rename()
    end, { desc = 'Rename (inc-rename.nvim)' }, buf)
    lsp_map(
      { 'workspace/didRenameFiles', 'workspace/willRenameFiles' },
      'n', '<leader>cR', function() Snacks.rename.rename_file() end, { desc = 'Rename File' }, buf
    )

    -- Symbols
    lsp_map('textDocument/documentSymbol', 'n', '<leader>ss', function() Snacks.picker.lsp_symbols() end, { desc = 'LSP Symbols' }, buf)
    lsp_map('workspace/symbol', 'n', '<leader>sS', function() Snacks.picker.lsp_workspace_symbols() end, { desc = 'LSP Workspace Symbols' }, buf)

    -- Codelens
    lsp_map('textDocument/codeLens', { 'n', 'x' }, '<leader>cc', vim.lsp.codelens.run, { desc = 'Run Codelens' }, buf)
    lsp_map('textDocument/codeLens', 'n', '<leader>cC', vim.lsp.codelens.refresh, { desc = 'Refresh & Display Codelens' }, buf)

    -- References navigation (Snacks.words)
    lsp_map('textDocument/documentHighlight', 'n', ']]', function() Snacks.words.jump(vim.v.count1) end, { desc = 'Next Reference' }, buf)
    lsp_map('textDocument/documentHighlight', 'n', '[[', function() Snacks.words.jump(-vim.v.count1) end, { desc = 'Prev Reference' }, buf)
    lsp_map('textDocument/documentHighlight', 'n', '<a-n>', function() Snacks.words.jump(vim.v.count1, true) end, { desc = 'Next Reference' }, buf)
    lsp_map('textDocument/documentHighlight', 'n', '<a-p>', function() Snacks.words.jump(-vim.v.count1, true) end, { desc = 'Prev Reference' }, buf)
  end,
})

-- Lint LSP priority: oxlint > biome > eslint (mutually exclusive)
local oxlint_configs = { '.oxlintrc.json', '.oxlintrc.jsonc', 'oxlint.config.ts', 'oxlint.config.js' }
local biome_configs = { 'biome.json', 'biome.jsonc' }
local eslint_configs = {
  '.eslintrc',
  '.eslintrc.cjs',
  '.eslintrc.js',
  '.eslintrc.json',
  '.eslintrc.yaml',
  '.eslintrc.yml',
  'eslint.config.cjs',
  'eslint.config.js',
  'eslint.config.mjs',
  'eslint.config.ts',
  'eslint.config.mts',
  'eslint.config.cts',
}

local has_oxlint = has_config(oxlint_configs)
local has_biome = has_config(biome_configs)
local has_eslint = has_config(eslint_configs)

-- Always enabled
local servers = {
  'astro',
  'bashls',
  'css_variables',
  'cssls',
  'dartls',
  'denols',
  'emmet_language_server',
  'fish_lsp',
  'gopls',
  'graphql',
  'harper_ls',
  'html',
  'jdtls',
  'jsonls',
  'just',
  'lemminx',
  'lua_ls',
  'marksman',
  'prismals',
  'sqls',
  'tailwindcss',
  'taplo',
  'vue_ls',
  'yamlls',
}

-- TypeScript: tsgo (primary) or vtsls (fallback)
-- When tsgo is active, vtsls is restricted to vue filetype only (hybrid mode)
if vim.g.tsgo_enabled then
  table.insert(servers, 'tsgo')
end
table.insert(servers, 'vtsls')

-- Docker: conditional on flag
if vim.g.docker_enabled then
  table.insert(servers, 'dockerls')
  table.insert(servers, 'docker_compose_language_service')
end

-- AI: Copilot native LSP
if vim.g.copilot_enabled then
  table.insert(servers, 'copilot')
end

-- Lint LSPs: mutually exclusive (oxlint > biome > eslint)
if has_oxlint then
  table.insert(servers, 'oxlint')
elseif has_biome then
  table.insert(servers, 'biome')
elseif has_eslint then
  table.insert(servers, 'eslint')
end

vim.lsp.enable(servers)
