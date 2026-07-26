---@type vim.lsp.Config
return {
  cmd = { 'yaml-language-server', '--stdio' },
  filetypes = { 'yaml', 'yaml.docker-compose' },
  root_markers = { '.git' },
  on_init = function(client)
    local ok, schemastore = pcall(require, 'schemastore')
    if ok then
      client.settings = vim.tbl_deep_extend('force', client.settings or {}, {
        yaml = {
          schemas = schemastore.yaml.schemas(),
        },
      })
    end

    -- Force enable formatting capability (yaml-language-server quirk)
    if client.server_capabilities then
      client.server_capabilities.documentFormattingProvider = true
    end

    client:notify('workspace/didChangeConfiguration', { settings = client.settings })
  end,
  settings = {
    redhat = { telemetry = { enabled = false } },
    yaml = {
      format = { enable = true },
      keyOrdering = false,
      schemaStore = { enable = false, url = '' },
      validate = true,
    },
  },
}
