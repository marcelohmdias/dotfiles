show_indicator() {
  local index=$1

  local prefix_prompt="WAIT"
  local copy_prompt="COPY"
  local sync_prompt="SYNC"
  local empty_prompt="TMUX"

  local prefix_style="#68bce7"
  local copy_style="#faec94"
  local sync_style="#d6a8a6"
  local empty_style="#a9d4d6"

  local icon=""
  local color="#{?client_prefix,$prefix_style,#{?pane_in_mode,$copy_style,#{?pane_synchronized,$sync_style,$empty_style}}}"
  local text="#{?client_prefix,$prefix_prompt,#{?pane_in_mode,$copy_prompt,#{?pane_synchronized,$sync_prompt,$empty_prompt}}}"

  local module=$( build_status_module "$index" "$icon" "$color" "$text" )

  echo "$module"
}
