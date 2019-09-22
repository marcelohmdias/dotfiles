#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" && . "./../utils.sh"

# -----------------------------------------------------------------------------

main() {
  local -r PPAS=( "graphics-drivers/ppa" )
  local -r NAMES=( "NVidia" )

  print_msg_sub_info "Drivers"
  run_list_ppas PPAS NAMES
}

# -----------------------------------------------------------------------------

main
break_line
