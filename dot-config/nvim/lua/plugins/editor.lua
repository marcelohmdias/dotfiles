if vim.g.lazyvim_default_config then
  return {}
end

return {
  { import = "plugins.config.colortils" },
  { import = "plugins.config.diffview" },
  { import = "plugins.config.dropbar" },
  { import = "plugins.config.git_conflict" },
  { import = "plugins.config.glance" },
  { import = "plugins.config.hover" },
  { import = "plugins.config.lazyvim" },
  { import = "plugins.config.markdown_table_mode" },
  { import = "plugins.config.neogit" },
  { import = "plugins.config.neominimap" },
  { import = "plugins.config.neotest" },
  { import = "plugins.config.nvim_highlight_colors" },
  { import = "plugins.config.nvim_scrollbar" },
  { import = "plugins.config.nvim_ufo" },
  { import = "plugins.config.obsidian" },
  { import = "plugins.config.peek" },
  { import = "plugins.config.render_markdown" },
  { import = "plugins.config.snacks_image" },
  { import = "plugins.config.snacks_picker" },
  { import = "plugins.config.symbol_usage" },
  { import = "plugins.config.telescope" },
  { import = "plugins.config.todo_comments" },
  { import = "plugins.config.treewalker" },
  { import = "plugins.config.vgit" },
  { import = "plugins.config.vim_tmux_navigator" },
  { import = "plugins.config.virt_column" },
  { import = "plugins.config.which_key" },
  { import = "plugins.config.yazi" },
}
