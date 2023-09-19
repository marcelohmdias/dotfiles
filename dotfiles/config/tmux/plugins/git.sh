get_format() {
  local module=$( build_status_module "$1" "$2" "$3" "$4" )

  echo "$module"
}

show_git() {
  local index=$1
  local icon="󰊢"
  local color="#d6a8a6"
  local text="#( gitmux -cfg $HOME/.config/tmux/gitmux.conf #{pane_current_path} )"


  echo "$text"
}
