local M = { gh('stevearc/conform.nvim') }

-- Web filetypes that use conditional formatter detection
local web_fts = {
  'astro', 'css', 'graphql', 'html', 'javascript', 'javascriptreact',
  'json', 'jsonc', 'markdown', 'scss', 'typescript', 'typescriptreact', 'vue',
}

--- Detect which web formatter to use based on project config files.
--- Priority: oxc_format > biome > prettierd
---@return string[]
local function web_formatter()
  local root = vim.uv.cwd() or '.'
  if vim.fs.root(root, { '.oxlintrc.json', 'oxlint.json' }) then
    return { 'oxc_format' }
  end
  if vim.fs.root(root, { 'biome.json', 'biome.jsonc' }) then
    return { 'biome' }
  end
  if vim.fs.root(root, { '.prettierrc', '.prettierrc.json', '.prettierrc.yml', '.prettierrc.yaml', '.prettierrc.js', '.prettierrc.cjs', '.prettierrc.mjs', '.prettierrc.toml', 'prettier.config.js', 'prettier.config.cjs', 'prettier.config.mjs' }) then
    return { 'prettierd' }
  end
  return {}
end

M.cmd = 'ConformInfo'

M.init = function()
  vim.api.nvim_create_autocmd('BufWritePre', {
    group = vim.api.nvim_create_augroup('minipack_format_on_save', { clear = true }),
    callback = function(ev)
      local baf = vim.b[ev.buf].autoformat
      if baf == false or (baf == nil and vim.g.autoformat == false) then return end
      local ok, conform = pcall(require, 'conform')
      if not ok then return end

      -- Detect per-buffer web formatter for web filetypes
      local ft = vim.bo[ev.buf].filetype
      if vim.tbl_contains(web_fts, ft) then
        local formatters = web_formatter()
        if #formatters > 0 then
          conform.format({ bufnr = ev.buf, formatters = formatters, lsp_format = 'fallback', timeout_ms = 3000 })
          return
        end
      end

      conform.format({ bufnr = ev.buf, lsp_format = 'fallback', timeout_ms = 3000 })
    end,
  })
end

M.keys = {
  {
    '<leader>cf',
    function()
      local ft = vim.bo.filetype
      local opts = { lsp_format = 'fallback', timeout_ms = 3000 }
      if vim.tbl_contains(web_fts, ft) then
        local formatters = web_formatter()
        if #formatters > 0 then
          opts.formatters = formatters
        end
      end
      require('conform').format(opts)
    end,
    mode = { 'n', 'x' },
    desc = 'Format',
  },
  {
    '<leader>cF',
    function()
      require('conform').format({ formatters = { 'injected' }, timeout_ms = 3000 })
    end,
    mode = { 'n', 'x' },
    desc = 'Format Injected Langs',
  },
}

---@module 'conform'
---@type conform.setupOpts
M.opts = {
  default_format_opts = {
    async = false,
    lsp_format = 'fallback',
    quiet = false,
    timeout_ms = 3000,
  },
  formatters = {
    injected = { options = { ignore_errors = true } },
  },
  formatters_by_ft = {
    dart = { 'dart_format' },
    fish = { 'fish_indent' },
    go = { 'goimports', 'gofumpt' },
    lua = { 'stylua' },
    sh = { 'shfmt' },
    sql = { 'sql_formatter' },
  },
}

return M
