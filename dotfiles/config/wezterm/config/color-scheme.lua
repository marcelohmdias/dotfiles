local M = {}

M.colors = {}
M.colors.tab_bar = {}
M.colors.tab_bar.active_tab = {}
M.colors.tab_bar.inactive_tab = {}
M.colors.tab_bar.inactive_tab_hover = {}
M.colors.tab_bar.new_tab = {}
M.colors.tab_bar.new_tab_hover = {}

M.colors.ansi = { "#282828", "#bd736e", "#66b373", "#e2b419", "#5689bc", "#ac72a9", "#8cb0b8", "#dadfe1" }

M.colors.brights = { "#5e6578", "#d6a8a6", "#a5d4a7", "#faec94", "#68bce7", "#ca9ee6", "#a9d4d6", "#fefefe" }

-- Background
M.colors.background = "#303446"
M.colors.foreground = "#c6d0f5"

-- Cursor
M.colors.compose_cursor = "#dadfe1"
M.colors.cursor_bg = "#dadfe1"
M.colors.cursor_border = "#dadfe1"
M.colors.cursor_fg = "#282828"

M.colors.scrollbar_thumb = "#626880"
M.colors.selection_bg = "#626880"
M.colors.selection_fg = "#c6d0f5"
M.colors.split = "#737994"
M.colors.visual_bell = "#414559"

-- Tab bar
M.colors.tab_bar.background = "#232634"
M.colors.tab_bar.inactive_tab_edge = "#414559"

M.colors.tab_bar.active_tab.bg_color = "#ca9ee6"
M.colors.tab_bar.active_tab.fg_color = "#232634"
M.colors.tab_bar.active_tab.intensity = "Normal"
M.colors.tab_bar.active_tab.italic = false
M.colors.tab_bar.active_tab.strikethrough = false
M.colors.tab_bar.active_tab.underline = "None"

M.colors.tab_bar.inactive_tab.bg_color = "#292c3c"
M.colors.tab_bar.inactive_tab.fg_color = "#c6d0f5"
M.colors.tab_bar.inactive_tab.intensity = "Normal"
M.colors.tab_bar.inactive_tab.italic = false
M.colors.tab_bar.inactive_tab.strikethrough = false
M.colors.tab_bar.inactive_tab.underline = "None"

M.colors.tab_bar.inactive_tab_hover.bg_color = "#303446"
M.colors.tab_bar.inactive_tab_hover.fg_color = "#c6d0f5"
M.colors.tab_bar.inactive_tab_hover.intensity = "Normal"
M.colors.tab_bar.inactive_tab_hover.italic = false
M.colors.tab_bar.inactive_tab_hover.strikethrough = false
M.colors.tab_bar.inactive_tab_hover.underline = "None"

M.colors.tab_bar.new_tab.bg_color = "#414559"
M.colors.tab_bar.new_tab.fg_color = "#c6d0f5"
M.colors.tab_bar.new_tab.intensity = "Normal"
M.colors.tab_bar.new_tab.italic = false
M.colors.tab_bar.new_tab.strikethrough = false
M.colors.tab_bar.new_tab.underline = "None"

M.colors.tab_bar.new_tab_hover.bg_color = "#51576d"
M.colors.tab_bar.new_tab_hover.fg_color = "#c6d0f5"
M.colors.tab_bar.new_tab_hover.intensity = "Normal"
M.colors.tab_bar.new_tab_hover.italic = false
M.colors.tab_bar.new_tab_hover.strikethrough = false
M.colors.tab_bar.new_tab_hover.underline = "None"

return M
