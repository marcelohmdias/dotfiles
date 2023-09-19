show_dir_name() {
  local index=$1
  local icon="󰉋"
  local color="#a9d4d6"
  local dir="#( echo \#{pane_current_path} | sed \"s|$HOME|home|\" | xargs basename )"
  local git="#( gitmux -cfg $HOME/.config/tmux/gitmux.conf #{pane_current_path} )"

  local text="$dir$git"

  local module=$( build_status_module "$index" "$icon" "$color" "$text" )

  echo "$module"
}
