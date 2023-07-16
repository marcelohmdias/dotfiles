local wez = require 'wezterm'
local utils = require 'utils.keybinds'
local Act = wez.action

local Keybinds = {}

Keybinds.keys = {}
Keybinds.key_tables = {}

Keybinds.leader = { key = 'Space', mods = 'CTRL', timeout_milliseconds = 100000 }

local map = utils:map_keys(Keybinds.keys)
local mapActivatePane = utils:map_actions(Keybinds.key_tables, 'activate_pane')
local mapResizePane = utils:map_actions(Keybinds.key_tables, 'resize_pane')

-- Copy and Paste selected line
map('c', 'CTRL|SHIFT', Act.CopyTo 'ClipboardAndPrimarySelection')
map('p', 'CTRL|SHIFT', Act.PasteFrom 'Clipboard')

-- Reload terminal configuration
map('u', 'LEADER', Act.ReloadConfiguration)

-- Open launcher
map('p', 'LEADER', Act.ShowLauncher)

-- Split horizontally
map('-', 'LEADER', Act.SplitVertical { domain = 'CurrentPaneDomain' })

-- Split vertically
map('\\', 'LEADER', Act.SplitHorizontal { domain = 'CurrentPaneDomain' })

-- Create new tab
map('n', 'LEADER', Act.SpawnTab 'CurrentPaneDomain' )

-- Close current tab
map('Q', 'LEADER', Act.CloseCurrentTab { confirm = true })

-- Close current panel
map('x', 'LEADER', Act.CloseCurrentPane { confirm = true })

-- Toggle fullscreen
map('m', 'LEADER', Act.ToggleFullScreen)

-- Show tab navigator
map('t', 'LEADER', Act.ShowTabNavigator)

-- Activates the copy mode
map('c', 'LEADER', Act.ActivateCopyMode)

-- Activates the debug overlay
map('L', 'LEADER', Act.ShowDebugOverlay)

-- Activates the copy mode
map('s', 'LEADER', Act.QuickSelect)

-- Change to tab
for i = 1, 9 do
  map(tostring(i), 'LEADER', Act.ActivateTab(i - 1) )
end

-- Navigate between panels
map('a', 'LEADER', Act.ActivateKeyTable { name = 'activate_pane', timeout_milliseconds = 1000 })
mapActivatePane({ 'h', 'LeftArrow' }, Act.ActivatePaneDirection 'Left')
mapActivatePane({ 'j', 'DownArrow' }, Act.ActivatePaneDirection 'Down')
mapActivatePane({ 'k', 'UpArrow'}, Act.ActivatePaneDirection 'Up')
mapActivatePane({ 'l', 'RightArrow' }, Act.ActivatePaneDirection 'Right')

-- Resize panels
map('r', 'LEADER', Act.ActivateKeyTable { name = 'resize_pane', one_shot = false })
mapResizePane({ 'h', 'LeftArrow' }, Act.AdjustPaneSize { 'Left', 1 })
mapResizePane({ 'j', 'DownArrow' }, Act.AdjustPaneSize { 'Down', 1 })
mapResizePane({ 'k', 'UpArrow'}, Act.AdjustPaneSize { 'Up', 1 })
mapResizePane({ 'l', 'RightArrow' }, Act.AdjustPaneSize { 'Right', 1 })
mapResizePane({ 'Escape' }, 'PopKeyTable')

return Keybinds
