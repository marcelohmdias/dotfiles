local M = { gh('nvim-treesitter/nvim-treesitter') }

M.cmd = { 'TSInstall', 'TSLog', 'TSUninstall', 'TSUpdate' }

M.config = function(_, opts)
  local TS = require('nvim-treesitter')

  if not TS.get_installed then
    vim.notify('[MiniPack] Please update nvim-treesitter to the main branch', vim.log.levels.ERROR)
    return
  end

  if type(opts.ensure_installed) ~= 'table' then
    vim.notify('[MiniPack] nvim-treesitter opts.ensure_installed must be a table', vim.log.levels.ERROR)
    return
  end

  TS.setup(opts)

  -- Install missing parsers
  local installed = TS.get_installed()
  local installed_set = {}
  for _, lang in ipairs(installed) do
    installed_set[lang] = true
  end

  local missing = vim.tbl_filter(function(lang)
    return not installed_set[lang]
  end, opts.ensure_installed)

  if #missing > 0 then
    TS.install(missing, { summary = true })
  end

  -- FileType autocmd for highlight, indent, folds
  vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('minipack_treesitter', { clear = true }),
    callback = function(ev)
      local ft = ev.match
      local lang = vim.treesitter.language.get_lang(ft)

      local function has_parser(filetype)
        local l = vim.treesitter.language.get_lang(filetype)
        return l and installed_set[l]
      end

      local function has_query(filetype, query)
        if not has_parser(filetype) then
          return false
        end
        local l = vim.treesitter.language.get_lang(filetype)
        local ok, result = pcall(vim.treesitter.query.get, l, query)
        return ok and result ~= nil
      end

      local function enabled(feat, query)
        local f = opts[feat] or {}
        return f.enable ~= false
          and not (type(f.disable) == 'table' and vim.tbl_contains(f.disable, lang))
          and has_query(ft, query)
      end

      if enabled('highlight', 'highlights') then
        pcall(vim.treesitter.start, ev.buf)
      end

      if enabled('indent', 'indents') then
        vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end

      if enabled('folds', 'folds') then
        local win = vim.fn.bufwinid(ev.buf)
        if win ~= -1 and vim.wo[win].foldmethod == 'manual' then
          vim.wo[win].foldmethod = 'expr'
          vim.wo[win].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
        end
      end
    end,
  })
end

M.event = { 'LazyFile', 'VeryLazy' }

---@module 'nvim-treesitter'
---@type TSConfig
M.opts = {
  ensure_installed = {
    'astro',
    'bash',
    'c',
    'css',
    'dart',
    'diff',
    'dockerfile',
    'editorconfig',
    'fish',
    'git_config',
    'git_rebase',
    'gitattributes',
    'gitcommit',
    'gitignore',
    'gherkin',
    'go',
    'gomod',
    'gosum',
    'gotmpl',
    'gowork',
    'graphql',
    'html',
    'http',
    'java',
    'javascript',
    'jsdoc',
    'json',
    'json5',
    'just',
    'lua',
    'luadoc',
    'luap',
    'markdown',
    'markdown_inline',
    'printf',
    'prisma',
    'python',
    'query',
    'regex',
    'scss',
    'sql',
    'tmux',
    'toml',
    'tsx',
    'typescript',
    'vim',
    'vimdoc',
    'vue',
    'xml',
    'yaml',
  },
  folds = { enable = true },
  highlight = { enable = true },
  indent = { enable = true },
}

M.version = 'main'

return M
