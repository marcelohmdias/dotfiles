#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" && . "./../utils.sh"

# -----------------------------------------------------------------------------

main() {
  local -r PPAS=( "lutris-team/lutris" )
  local -r NAMES=( "Lutris" )

  print_msg_sub_info "Apps"
  run_list_ppas PPAS NAMES
}

# -----------------------------------------------------------------------------

main
break_line
