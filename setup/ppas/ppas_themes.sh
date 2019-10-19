#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" && . "./../utils.sh"

# ------------------------------------------------------------------------------

main() {
  print_msg_sub_info "Themes"

  run_list_ppas "daniruiz/flat-remix"   "Flat Remix"
  # run_list_ppas "snwh/ppa"              "Paper"
  run_list_ppas "papirus/papirus"       "Papirus"
}

# ------------------------------------------------------------------------------

main
break_line
