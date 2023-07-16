require "listener"

local Fonts = require "fonts"
local Keybinds = require "keybinds"

local Format = require "utils.format"

local M = {}

-- COLORS
M.colors = require "color_shemes"

-- KEYBINDS
M.leader = Keybinds.leader
M.keys = Keybinds.keys
M.key_tables = Keybinds.key_tables

-- CURSOR
M.cursor_blink_ease_in = "Constant"
M.cursor_blink_ease_out = "Constant"
M.cursor_blink_rate = 500
M.default_cursor_style = "BlinkingBar"

-- FONT
M.font = Fonts.fira_code
M.font_rules = Fonts.font_rules
M.font_size = Fonts.size
M.hyperlink_rules = require "hyperlink_rules"

-- GUI
M.automatically_reload_config = false
M.check_for_updates = false
M.detect_password_input = false
M.detect_password_input = false
M.front_end = "WebGpu"
M.hide_mouse_cursor_when_typing = true
M.inactive_pane_hsb = {
  saturation = 0.7,
  brightness = 0.5,
}
M.initial_cols = 120
M.initial_rows = 30
M.tab_bar_at_bottom = true
M.term = "xterm-256color"
M.use_fancy_tab_bar = false
M.window_background_opacity = 0.85
M.window_close_confirmation = "NeverPrompt"
M.window_padding = {
  left = "1px",
  right = "1px",
  top = "1px",
  bottom = "-1cell",
}

-- Applications
M.launch_menu = {
  { args = { "tig" },     label = Format:to_format("Tig", " - ") },
  { args = { "htop" },    label = Format:to_format("HTop", " - ") },
  { args = { "btop" },  label = Format:to_format("BTop", " - ") },
  { args = { "lazygit" }, label = Format:to_format("LazyGit", " - ") },
}

return M
