local M = {}

-- COMMAND PALETTE
M.command_palette_font_size = 11.0
M.command_palette_bg_color = "#51576d"
M.command_palette_fg_color = "#c6d0f5"

-- CURSOR
M.cursor_blink_ease_in = "Constant"
M.cursor_blink_ease_out = "Constant"
M.cursor_blink_rate = 500
M.default_cursor_style = "BlinkingBar"
M.detect_password_input = false
M.detect_password_input = false

-- MOUSE
M.hide_mouse_cursor_when_typing = true

-- TAB
M.switch_to_last_active_tab_when_closing_tab = true
M.tab_bar_at_bottom = true
M.tab_max_width = 18
M.use_fancy_tab_bar = false

-- PANES
M.inactive_pane_hsb = {
  saturation = 0.7,
  brightness = 0.5,
}

-- RENDER TERM
M.front_end = "WebGpu"
M.term = "xterm-256color"
M.webgpu_power_preference = "HighPerformance"

-- WINDOW
M.initial_cols = 120
M.initial_rows = 30
M.window_background_opacity = 0.85
M.window_close_confirmation = "NeverPrompt"
M.window_padding = {
  left = "1px",
  right = "1px",
  top = "1px",
  bottom = "-1cell",
}
M.window_decorations = "TITLE | RESIZE"
M.adjust_window_size_when_changing_font_size = false

-- NOTIFY
M.audible_bell = "SystemBeep"
M.visual_bell = {
  fade_in_function = "EaseIn",
  fade_in_duration_ms = 150,
  fade_out_function = "EaseOut",
  fade_out_duration_ms = 150,
  target = "CursorColor",
}

return M
