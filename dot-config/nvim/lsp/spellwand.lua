---@type vim.lsp.Config
return {
  filetypes = {
    'astro',
    'css',
    'dart',
    'fish',
    'go',
    'graphql',
    'html',
    'java',
    'javascript',
    'javascriptreact',
    'json',
    'just',
    'lua',
    'prisma',
    'python',
    'scss',
    'sql',
    'toml',
    'typescript',
    'typescriptreact',
    'vue',
    'xml',
    'yaml',
  },
  settings = {
    spellwand = {
      cond = function(bufnr)
        local bo = vim.bo[bufnr]
        if bo.readonly or bo.buftype ~= '' then
          return false
        end
        if vim.api.nvim_buf_line_count(bufnr) > 10000 then
          return false
        end
        return true
      end,
      debounce_ms = 300,
      max_errors = 500,
      num_suggestions_in_code_action = 5,
      num_suggestions_in_diagnostics = 0,
      preprocess = function(_, spell_errors)
        return vim.tbl_filter(function(err)
          return #err.word > 2
        end, spell_errors)
      end,
      severity = {
        SpellBad = vim.diagnostic.severity.HINT,
        SpellCap = vim.diagnostic.severity.HINT,
        SpellLocal = vim.diagnostic.severity.HINT,
        SpellRare = vim.diagnostic.severity.HINT,
      },
      strategies = { 'treesitter', 'full' },
    },
  },
}
