#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" && . "./../utils.sh"

# ------------------------------------------------------------------------------

main() {
  local -r PPAS=( "daniruiz/flat-remix" "snwh/ppa" "papirus/papirus" )
  local -r NAMES=( "Flat Remix" "Paper" "Papirus" )

  print_msg_sub_info "Themes"
  run_list_ppas PPAS NAMES
}

# ------------------------------------------------------------------------------

main
break_line
