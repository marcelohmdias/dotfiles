---@type vim.lsp.Config
return {
  cmd = { 'vscode-json-language-server', '--stdio' },
  filetypes = { 'json', 'jsonc', 'json5' },
  init_options = { provideFormatter = true },
  root_markers = { '.git' },
  before_init = function(_, config)
    pcall(vim.cmd.packadd, 'schemastore')
    local ok, schemastore = pcall(require, 'schemastore')
    if not ok then
      return
    end

    config.settings = config.settings or {}
    config.settings.json = config.settings.json or {}
    config.settings.json.schemas = schemastore.json.schemas()
    config.settings.json.validate = { enable = true }
  end,
}
