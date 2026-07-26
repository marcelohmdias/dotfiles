---@type vim.lsp.Config
return {
  cmd = { 'tailwindcss-language-server', '--stdio' },
  filetypes = {
    'astro',
    'css',
    'html',
    'javascriptreact',
    'less',
    'mdx',
    'scss',
    'typescriptreact',
    'vue',
  },
  root_markers = {
    'tailwind.config.cjs',
    'tailwind.config.js',
    'tailwind.config.mjs',
    'tailwind.config.ts',
    'postcss.config.cjs',
    'postcss.config.js',
    'postcss.config.mjs',
    'postcss.config.ts',
    '.git',
  },
  settings = {
    tailwindCSS = {
      classAttributes = { 'class', 'className', 'class:list', 'classList', 'ngClass' },
      includeLanguages = {
        vue = 'html',
        typescriptreact = 'html',
        javascriptreact = 'html',
      },
      lint = {
        cssConflict = 'warning',
        invalidApply = 'error',
        invalidConfigPath = 'error',
        invalidScreen = 'error',
        invalidTailwindDirective = 'error',
        invalidVariant = 'error',
        recommendedVariantOrder = 'warning',
      },
      validate = true,
    },
  },
  workspace_required = true,
}
