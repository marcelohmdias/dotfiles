#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" && . "./../utils.sh"

# ------------------------------------------------------------------------------

main() {
  local -r PPAS=( "git-core/ppa" "dawidd0811/neofetch" )
  local -r NAMES=( "Git" "Neofetch" )

  print_msg_sub_info "Tools"
  run_list_ppas PPAS NAMES
}

# ------------------------------------------------------------------------------

main
break_line

