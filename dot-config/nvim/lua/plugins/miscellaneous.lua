if vim.g.lazyvim_default_config then
  return {}
end

return {
  { import = "plugins.config.key_analyzer" },
  { import = "plugins.config.hardtime" },
  { import = "plugins.config.mise" },
  { import = "plugins.config.minty" },
  { import = "plugins.config.output_panel" },
  { import = "plugins.config.package_info" },
  { import = "plugins.config.precognition" },
  { import = "plugins.config.showkeys" },
  { import = "plugins.config.timerly" },
  { import = "plugins.config.typr" },
  { import = "plugins.config.urlview" },
  { import = "plugins.config.vim_be_good" },
  { import = "plugins.config.vim_wakatime" },
  { import = "plugins.config.wezterm" },
}
