#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" && . "./../utils.sh"

# -----------------------------------------------------------------------------

main() {
  local -r PPAS=( "lutris-team/lutris" "libratbag-piper/piper-libratbag-git" )
  local -r NAMES=( "Lutris" "Piper" )

  print_msg_sub_info "Apps"
  run_list_ppas PPAS NAMES
}

# -----------------------------------------------------------------------------

main
break_line
