#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" && . "./../utils.sh"

# ------------------------------------------------------------------------------

main() {
  print_msg_sub_info "Apps"

  run_list_ppas "lutris-team/lutris"                    "Lutris"
  run_list_ppas "libratbag-piper/piper-libratbag-git"   "Piper"
}

# ------------------------------------------------------------------------------

main
break_line
