--- TODO: move icons to config.icons
local M = { "MeanderingProgrammer/render-markdown.nvim" }

M.dependencies = {
  "nvim-treesitter/nvim-treesitter",
  "echasnovski/mini.nvim",
}

M.event = "LazyFile"

M.keys = {
  { "<leader>uR", "<Cmd>RenderMarkdown toggle<CR>", desc = "Toggle RenderMarkdown" },
}

---@class  render.md.UserConfig
M.opts = {
  checkbox = {
    checked = { icon = " " },
    unchecked = { icon = " " },
    custom = {
      bookmark = { raw = "[b]", rendered = " ", highlight = "RenderMarkdownH2" },
      cancelled = { raw = "[-]", rendered = " ", highlight = "RenderMarkdownError" },
      cons = { raw = "[c]", rendered = " ", highlight = "RenderMarkdownError" },
      down = { raw = "[d]", rendered = "󰔳 ", highlight = "RenderMarkdownError" },
      fire = { raw = "[f]", rendered = " ", highlight = "RenderMarkdownH2" },
      forwarded = { raw = "[>]", rendered = " ", highlight = "RenderMarkdownInfo" },
      idea = { raw = "[I]", rendered = " ", highlight = "RenderMarkdownWarn" },
      important = { raw = "[!]", rendered = " ", highlight = "RenderMarkdownH2" },
      incompleted = { raw = "[/]", rendered = " ", highlight = "RenderMarkdownCodeInline" },
      information = { raw = "[i]", rendered = " ", highlight = "RenderMarkdownInfo" },
      key = { raw = "[k]", rendered = " ", highlight = "RenderMarkdownWarn" },
      location = { raw = "[l]", rendered = " ", highlight = "RenderMarkdownH2" },
      pros = { raw = "[p]", rendered = " ", highlight = "RenderMarkdownChecked" },
      question = { raw = "[?]", rendered = " ", highlight = "RenderMarkdownWarn" },
      quote = { raw = '["]', rendered = "󱀢 ", highlight = "RenderMarkdownSuccess" },
      savings = { raw = "[S]", rendered = " ", highlight = "RenderMarkdownChecked" },
      scheduled = { raw = "[<]", rendered = " ", highlight = "RenderMarkdownHint" },
      star = { raw = "[*]", rendered = " ", highlight = "RenderMarkdownWarn" },
      todo = { raw = "[ ]", rendered = " ", highlight = "RenderMarkdownTodo" },
      up = { raw = "[u]", rendered = "󰔵 ", highlight = "RenderMarkdownChecked" },
      win = { raw = "[w]", rendered = " ", highlight = "RenderMarkdownH6" },
    },
  },
  heading = {
    icons = { "󰼏 ", "󰎨 ", "󰼑 ", "󰎲 ", "󰼓 ", "󰎴 " },
  },
  pipe_table = {
    preset = "round",
  },
  preset = "obsidian",
}

return M
