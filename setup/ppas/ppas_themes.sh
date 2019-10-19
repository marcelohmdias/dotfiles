#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" && . "./../utils.sh"

# ------------------------------------------------------------------------------

main() {
  print_msg_sub_info "Themes"

  add_ppa "daniruiz/flat-remix"   "Flat Remix"
  # add_ppa "snwh/ppa"              "Paper"
  add_ppa "papirus/papirus"       "Papirus"
}

# ------------------------------------------------------------------------------

main
break_line
