local wez = require "wezterm"
local utils = require "utils.mapper"
local Act = wez.action

local M = {}

M.keys = {}
M.key_tables = {}
M.mouse_bindings = {}

M.leader = { key = "Space", mods = "CTRL", timeout_milliseconds = 100000 }

local bind = utils:create_bind_events(M.mouse_bindings)
local map = utils:create_map_keys(M.keys)
local mapActivatePane = utils:creae_map_actions(M.key_tables, "activate_pane")
local mapResizePane = utils:creae_map_actions(M.key_tables, "resize_pane")
local mapTmuxActions = utils:creae_map_actions(M.key_tables, "tmux")
local mapVimActions = utils:creae_map_actions(M.key_tables, "vim")

local tmux = function(key, mod, action)
  map(
    key,
    mod,
    Act.Multiple {
      Act.ActivateKeyTable { name = "tmux", timeout_milliseconds = 1000 },
      Act.SendKey { key = "a", mods = "CTRL" },
      Act.SendKey(action),
    }
  )
end

-- Bind 'Up' event of CTRL-Click to open hyperlinks
bind({ Up = { streak = 1, button = "Left" } }, "CTRL", Act.OpenLinkAtMouseCursor)

-- Bind and map to change font ResetFontSize
bind({ Down = { streak = 1, button = { WheelUp = 1 } } }, "CTRL", Act.IncreaseFontSize)
bind({ Down = { streak = 1, button = { WheelDown = 1 } } }, "CTRL", Act.DecreaseFontSize)
map("0", "CTRL", Act.ResetFontSize)

-- Copy and Paste selected line
map("C", "CTRL|SHIFT", Act.CopyTo "ClipboardAndPrimarySelection")
map("V", "CTRL|SHIFT", Act.PasteFrom "Clipboard")

-- Open Command Palette
map("P", "CTRL|SHIFT", Act.ActivateCommandPalette)

-- Activates the debug overlay
map("L", "CTRL|SHIFT", Act.ShowDebugOverlay)

-- Activates the copy mode
map("Space", "CTRL|SHIFT", Act.QuickSelect)

-- Reload terminal configuration
map("u", "LEADER", Act.ReloadConfiguration)

-- Split horizontally
map("-", "LEADER", Act.SplitVertical { domain = "CurrentPaneDomain" })

-- Split vertically
map("\\", "LEADER", Act.SplitHorizontal { domain = "CurrentPaneDomain" })

-- Create new tab
map("n", "LEADER", Act.SpawnTab "CurrentPaneDomain")

-- Close current tab
map("Q", "LEADER", Act.CloseCurrentTab { confirm = true })

-- Close current panel
map("q", "LEADER", Act.CloseCurrentPane { confirm = true })

-- Toggle fullscreen
map("m", "LEADER", Act.ToggleFullScreen)

-- Open launcher menu
map("p", "LEADER", Act.ShowLauncher)

-- Activates the copy mode
map("c", "LEADER", Act.ActivateCopyMode)

-- Activates the zoom mode in panels
map("z", "LEADER", Act.TogglePaneZoomState)

-- Open tab navigator
map("t", "LEADER", Act.ShowTabNavigator)

-- Activates the  pane selection modal display
map("a", "ALT", Act.PaneSelect)

-- Rotates the sequence of panes
map("[", "CTRL", Act.RotatePanes "Clockwise")
map("]", "CTRL", Act.RotatePanes "CounterClockwise")

-- Change to tab
for i = 1, 9 do
  map(tostring(i), "LEADER", Act.ActivateTab(i - 1))
end

-- Navigate between panels
map("d", "LEADER", Act.ActivateKeyTable { name = "activate_pane", timeout_milliseconds = 1000 })
mapActivatePane({ "h", "LeftArrow" }, Act.ActivatePaneDirection "Left")
mapActivatePane({ "j", "DownArrow" }, Act.ActivatePaneDirection "Down")
mapActivatePane({ "k", "UpArrow" }, Act.ActivatePaneDirection "Up")
mapActivatePane({ "l", "RightArrow" }, Act.ActivatePaneDirection "Right")

-- Resize panels
map("r", "LEADER", Act.ActivateKeyTable { name = "resize_pane", one_shot = false })
mapResizePane({ "h", "LeftArrow" }, Act.AdjustPaneSize { "Left", 5 })
mapResizePane({ "j", "DownArrow" }, Act.AdjustPaneSize { "Down", 5 })
mapResizePane({ "k", "UpArrow" }, Act.AdjustPaneSize { "Up", 5 })
mapResizePane({ "l", "RightArrow" }, Act.AdjustPaneSize { "Right", 5 })
mapResizePane({ "Escape" }, "PopKeyTable")

-- Tmux action
map(
  "a",
  "LEADER",
  Act.Multiple {
    Act.ActivateKeyTable { name = "tmux", timeout_milliseconds = 5000 },
    Act.SendKey { key = "a", mods = "CTRL" },
  }
)
tmux("\\", "CTRL|ALT", { key = "\\" }) -- Vertical split pane
tmux("-", "CTRL|ALT", { key = "-" }) -- Horizontal split pane
tmux("[", "CTRL|ALT", { key = "[" }) -- Copy mode
tmux("h", "CTRL|SHIFT|ALT", { key = "H" }) -- Move to left
tmux("j", "CTRL|SHIFT|ALT", { key = "J" }) -- Move to up
tmux("k", "CTRL|SHIFT|ALT", { key = "K" }) -- Move to down
tmux("l", "CTRL|SHIFT|ALT", { key = "L" }) -- Move to right
tmux("n", "CTRL|ALT", { key = "n" }) -- New window
tmux("r", "CTRL|ALT", { key = "r" }) -- Reload configuration
tmux("t", "CTRL|ALT", { key = "t" }) -- Tmux session manager modal
tmux("x", "CTRL|ALT", { key = "x" }) -- Kill window or pane
tmux("z", "CTRL|ALT", { key = "z" }) -- Zoom pane
for i = 1, 9 do
  tmux(tostring(i), "CTRL|ALT", { key = tostring(i) }) -- Change to tab
end
mapTmuxActions({ "Escape" }, "PopKeyTable")

-- Vim action
map(
  "Space",
  "LEADER",
  Act.Multiple {
    Act.ActivateKeyTable { name = "vim", timeout_milliseconds = 5000 },
    Act.SendKey { key = "Space" },
  }
)
mapTmuxActions({ "Escape" }, "PopKeyTable")

return M
