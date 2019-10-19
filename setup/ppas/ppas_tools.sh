#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" && . "./../utils.sh"

# ------------------------------------------------------------------------------

main() {
  print_msg_sub_info "Tools"

  run_list_ppas "git-core/ppa"            "Git"
  run_list_ppas "dawidd0811/neofetch"     "Neofetch"
}

# ------------------------------------------------------------------------------

main
break_line

