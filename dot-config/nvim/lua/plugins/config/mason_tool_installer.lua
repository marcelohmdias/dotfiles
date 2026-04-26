local M = { gh('WhoIsSethDaniel/mason-tool-installer.nvim') }

M.cmd = { 'MasonToolsInstall', 'MasonToolsUpdate', 'MasonToolsClean' }

M.dependencies = { gh('mason-org/mason.nvim') }

M.event = 'LazyFile'

---@type MasonToolInstallerSettings
M.opts = {
  ensure_installed = {
    -- LSP servers
    'astro-language-server',
    'bash-language-server',
    'biome',
    'copilot-language-server',
    'css-lsp',
    'css-variables-language-server',
    'dockerfile-language-server',
    'docker-compose-language-service',
    'emmet-language-server',
    'eslint-lsp',
    'gopls',
    'graphql-language-service-cli',
    'harper-ls',
    'html-lsp',
    'jdtls',
    'json-lsp',
    'lemminx',
    'lua-language-server',
    'marksman',
    'oxlint',
    'prisma-language-server',
    'sqls',
    'tailwindcss-language-server',
    'taplo',
    'vtsls',
    'vue-language-server',
    'yaml-language-server',

    -- Formatters
    'gofumpt',
    'goimports',
    'prettierd',
    'shfmt',
    'sql-formatter',
    'stylua',

    -- Linters
    'commitlint',
    'cspell',

    -- DAP adapters
    'delve',
    'js-debug-adapter',

    -- Go tools
    'gomodifytags',
    'impl',
  },
  auto_update = false,
  run_on_start = true,
}

return M
