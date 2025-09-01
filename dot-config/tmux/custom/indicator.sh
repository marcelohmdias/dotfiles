show_indicator() {
  local index=$1

  local prefix_prompt="WAIT"
  local copy_prompt="COPY"
  local sync_prompt="SYNC"
  local empty_prompt="TMUX"

  local prefix_style="#99d1db"
  local copy_style="#e5c890"
  local sync_style="#ea999c"
  local empty_style="#babbf1"

  local icon=""
  local color="#{?client_prefix,$prefix_style,#{?pane_in_mode,$copy_style,#{?pane_synchronized,$sync_style,$empty_style}}}"
  local text="#{?client_prefix,$prefix_prompt,#{?pane_in_mode,$copy_prompt,#{?pane_synchronized,$sync_prompt,$empty_prompt}}}"

  local module=$( build_status_module "$index" "$icon" "$color" "$text" )

  echo "$module"
}
