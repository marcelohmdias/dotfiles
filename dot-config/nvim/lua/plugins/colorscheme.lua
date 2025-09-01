if vim.g.lazyvim_default_config then
  return {}
end

return {
  { import = "plugins.config.catppuccin" },
}
