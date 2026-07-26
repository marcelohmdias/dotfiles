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

---@type vim.lsp.Config
return {
  cmd = { 'vscode-eslint-language-server', '--stdio' },
  filetypes = {
    'astro',
    'javascript',
    'javascriptreact',
    'typescript',
    'typescriptreact',
    'vue',
  },
  root_markers = eslint_configs,
  settings = {
    codeAction = {
      disableRuleComment = { enable = true, location = 'separateLine' },
      showDocumentation = { enable = true },
    },
    codeActionOnSave = { enable = false, mode = 'all' },
    format = false,
    nodePath = '',
    problems = { shortenToSingleLine = false },
    quiet = false,
    rulesCustomizations = {},
    run = 'onType',
    validate = 'on',
    workingDirectory = { mode = 'location' },
  },
  workspace_required = true,
}
