---@type vim.lsp.Config
return {
  cmd = { 'vscode-json-language-server', '--stdio' },
  filetypes = { 'json', 'jsonc' },
  init_options = { provideFormatter = true },
  root_markers = { '.git' },
  on_init = function(client)
    local ok, schemastore = pcall(require, 'schemastore')
    if not ok then return end

    client.settings = vim.tbl_deep_extend('force', client.settings or {}, {
      json = {
        schemas = schemastore.json.schemas(),
        validate = { enable = true },
      },
    })
    client:notify('workspace/didChangeConfiguration', { settings = client.settings })
  end,
}
