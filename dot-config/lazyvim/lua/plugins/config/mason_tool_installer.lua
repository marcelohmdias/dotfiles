local M = { "WhoIsSethDaniel/mason-tool-installer.nvim" }

M.cmd = { "MasonToolsInstall", "MasonToolsUpdate", "MasonToolsClean" }

M.opts = {
  ensure_installed = {
    "astro-language-server",
    "bash-debug-adapter",
    "bash-language-server",
    "cspell",
    "commitlint",
    "custom-elements-languageserver",
    "css-lsp",
    "cssls",
    "css-variables-language-server",
    "denols",
    "editorconfig-checker",
    "emmet-language-server",
    "graphql-language-service-cli",
    "harper-ls",
    "html-lsp",
    "js-debug-adapter",
  },
}

return M
