local M = { gh('folke/snacks.nvim') }

M.keys = {
  {
    '<leader>fe',
    function()
      Snacks.explorer({ cwd = MiniPack.root() })
    end,
    desc = 'Explorer (Root Dir)',
  },
  {
    '<leader>fE',
    function()
      Snacks.explorer()
    end,
    desc = 'Explorer (cwd)',
  },
  { '<leader>e', '<leader>fe', desc = 'Explorer (Root Dir)', remap = true },
  { '<leader>E', '<leader>fE', desc = 'Explorer (cwd)', remap = true },
}

---@type snacks.Config
M.opts = {
  explorer = {
    auto_close = true,
    layout = {
      layout = {
        width = 45,
        min_width = 45,
      },
    },
  },
}

return M
