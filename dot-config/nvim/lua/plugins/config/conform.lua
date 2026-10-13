local M = { gh('stevearc/conform.nvim') }

-- Web filetypes that use conditional formatter detection
local web_fts = {
  'astro',
  'css',
  'graphql',
  'html',
  'javascript',
  'javascriptreact',
  'json',
  'jsonc',
  'markdown',
  'scss',
  'typescript',
  'typescriptreact',
  'vue',
}

--- Detect which web formatter to use based on project config files.
--- Uses the current buffer's root when available, falling back to cwd.
--- Priority: oxc_format > prettierd > biome-check > LSP fallback
---@param buf number
---@return string[]
local function web_formatter(buf)
  local name = vim.api.nvim_buf_get_name(buf)
  local root = name ~= '' and vim.fs.root(name, '.') or vim.uv.cwd() or '.'
  if vim.fs.root(root, { '.oxlintrc.json', 'oxlint.json' }) then
    return { 'oxc_format' }
  end
  if
    vim.fs.root(root, {
      '.prettierrc',
      '.prettierrc.json',
      '.prettierrc.yml',
      '.prettierrc.yaml',
      '.prettierrc.js',
      '.prettierrc.cjs',
      '.prettierrc.mjs',
      '.prettierrc.toml',
      'prettier.config.js',
      'prettier.config.cjs',
      'prettier.config.mjs',
    })
  then
    return { 'prettierd' }
  end
  if vim.fs.root(root, { 'biome.json', 'biome.jsonc' }) then
    return { 'biome-check' }
  end
  return {}
end

M.cmd = 'ConformInfo'

M.init = function()
  vim.api.nvim_create_autocmd('BufWritePre', {
    group = vim.api.nvim_create_augroup('minipack_format_on_save', { clear = true }),
    callback = function(ev)
      local baf = vim.b[ev.buf].autoformat
      if baf == false or (baf == nil and vim.g.autoformat == false) then
        return
      end
      local ok, conform = pcall(require, 'conform')
      if not ok then
        return
      end
      conform.format({ bufnr = ev.buf, lsp_format = 'fallback', timeout_ms = 3000 })
    end,
  })
end

M.keys = {
  {
    '<leader>cf',
    function()
      require('conform').format({ lsp_format = 'fallback', timeout_ms = 3000 })
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
  {
    '<leader>uf',
    function()
      vim.g.autoformat = not (vim.g.autoformat == true)
      local state = vim.g.autoformat and 'enabled' or 'disabled'
      vim.notify('[Format] autoformat ' .. state, vim.log.levels.INFO)
    end,
    mode = 'n',
    desc = 'Toggle Autoformat (global)',
  },
  {
    '<leader>uF',
    function()
      local buf = vim.api.nvim_get_current_buf()
      vim.b[buf].autoformat = not (vim.b[buf].autoformat == true)
      local state = vim.b[buf].autoformat and 'enabled' or 'disabled'
      vim.notify('[Format] buffer autoformat ' .. state, vim.log.levels.INFO)
    end,
    mode = 'n',
    desc = 'Toggle Autoformat (buffer)',
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
    ['biome-check'] = {
      require_cwd = true,
      cwd = function(self, ctx)
        return vim.fs.root(ctx.dirname, { 'biome.json', 'biome.jsonc' })
      end,
    },
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

-- Register the web filetype formatter resolver dynamically so both
-- format-on-save and `gq` (via formatexpr) use the same project-aware pipeline.
for _, ft in ipairs(web_fts) do
  M.opts.formatters_by_ft[ft] = function(buf)
    return web_formatter(buf)
  end
end

return M
