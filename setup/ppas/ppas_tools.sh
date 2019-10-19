#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" && . "./../utils.sh"

# ------------------------------------------------------------------------------

main() {
  print_msg_sub_info "Tools"

  add_ppa "git-core/ppa"            "Git"
  add_ppa "dawidd0811/neofetch"     "Neofetch"
}

# ------------------------------------------------------------------------------

main
break_line

