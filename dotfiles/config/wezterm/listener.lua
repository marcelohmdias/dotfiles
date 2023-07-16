local wez = require 'wezterm'
local Format = require 'utils.format'

local function tab_title(tab_info)
  local title = tab_info.tab_title
  if title and #title > 0 then
    return title
  end
  return tab_info.active_pane.title
end

wez.on('format-tab-title', function(tab)
  local title = tab_title(tab)
  return Format:to_format(title)
end)

wez.on('update-status', function(window)
  local left_status = ''
  local right_status = ''
  local name = window:active_key_table()

  if name then
    right_status =  Format:to_format(name)
  else
    local time = wez.time.now()
    local calendar = Format:with_icon('calendar', time:format("%a, %e %b"))
    local clock = Format:with_icon('clock', time:format("%X"))
    right_status = calendar .. clock .. ' '
  end

  if window:leader_is_active() then
    left_status = Format:with_icon('MOD', '')
  end

  window:set_left_status(Format:to_leader(left_status))
  window:set_right_status(Format:to_command(right_status))
end)
