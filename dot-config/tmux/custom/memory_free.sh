show_memory_free() {
  local index icon color text module

  index=$1
  icon="󰍛"
  color="#d6a8a6"
  text="#{memory_free}Gb"

  module=$(build_status_module "$index" "$icon" "$color" "$text")

  echo "$module"
}
