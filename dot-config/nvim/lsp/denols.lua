---@type vim.lsp.Config
return {
  cmd = { 'deno', 'lsp' },
  cmd_env = { NO_COLOR = '1' },
  filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
  root_markers = { 'deno.json', 'deno.jsonc', 'deno.lock' },
  settings = {
    deno = {
      enable = true,
      suggest = {
        imports = {
          hosts = {
            ['https://deno.land'] = true,
          },
        },
      },
    },
  },
  workspace_required = true,
}
