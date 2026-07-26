if vim.g.lazyvim_default_config then
  return {}
end

return {
  { import = "plugins.config.garbage_day" },
  { import = "plugins.config.mason" },
  { import = "plugins.config.mason_tool_installer" },
  { import = "plugins.config.nvim_lspconfig" },
  { import = "plugins.config.ts_error_translator" },
  { import = "plugins.config.tsc" },
}
