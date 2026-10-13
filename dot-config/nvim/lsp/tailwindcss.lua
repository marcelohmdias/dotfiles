---@type vim.lsp.Config
return {
  cmd = { 'tailwindcss-language-server', '--stdio' },
  filetypes = {
    'astro',
    'css',
    'eelixir',
    'elixir',
    'eruby',
    'heex',
    'html',
    'javascript',
    'javascriptreact',
    'less',
    'php',
    'postcss',
    'ruby',
    'sass',
    'scss',
    'svelte',
    'templ',
    'typescript',
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
  before_init = function(_, config)
    config.settings = config.settings or {}
    config.settings.tailwindCSS = config.settings.tailwindCSS or {}
    config.settings.tailwindCSS.editor = config.settings.tailwindCSS.editor or {}
    if config.settings.tailwindCSS.editor.tabSize == nil then
      config.settings.tailwindCSS.editor.tabSize = vim.lsp.util.get_effective_tabstop()
    end
  end,
  settings = {
    tailwindCSS = {
      classAttributes = { 'class', 'className', 'class:list', 'classList', 'ngClass' },
      includeLanguages = {
        eelixir = 'html-eex',
        elixir = 'html-eex',
        eruby = 'erb',
        heex = 'html-eex',
        templ = 'html',
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
