if vim.g.lazyvim_default_config then
  return {}
end

return {
  { import = "plugins.config.actions_preview" },
  { import = "plugins.config.better_escape" },
  { import = "plugins.config.blink_cmp" },
  { import = "plugins.config.coerce" },
  { import = "plugins.config.duplicate" },
  { import = "plugins.config.patterns" },
  { import = "plugins.config.template_string" },
  { import = "plugins.config.treesj" },
  { import = "plugins.config.vim_visual_multi" },
}
