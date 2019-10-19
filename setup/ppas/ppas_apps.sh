#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" && . "./../utils.sh"

# ------------------------------------------------------------------------------

main() {
  print_msg_sub_info "Apps"

  add_ppa "lutris-team/lutris"                    "Lutris"
  add_ppa "libratbag-piper/piper-libratbag-git"   "Piper"
}

# ------------------------------------------------------------------------------

main
break_line
