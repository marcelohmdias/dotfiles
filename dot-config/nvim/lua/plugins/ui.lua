if vim.g.lazyvim_default_config then
  return {}
end

return {
  { import = "plugins.config.bufferline" },
  { import = "plugins.config.dressing" },
  { import = "plugins.config.edgy" },
  { import = "plugins.config.lualine" },
  { import = "plugins.config.mini_icons" },
  { import = "plugins.config.noice" },
  { import = "plugins.config.snacks_dashboard" },
  { import = "plugins.config.snacks_statuscolumn" },
  { import = "plugins.config.snacks_win" },
  { import = "plugins.config.tailwind_fold" },
  { import = "plugins.config.tiny_devicons_auto_colors" },
}
