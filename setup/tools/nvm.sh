#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" && . "./../utils.sh"

# -----------------------------------------------------------------------------

main() {
  local -a version="v0.35.2"
  local -a url="https://raw.githubusercontent.com/nvm-sh/nvm/$version/install.sh"

  print_msg_sub_info "NVM"

  if cmd_exists "nvm"; then
    print_msg_success "NVM Installed"
  else
    execute "wget -qO- $url | bash &> /dev/null" "Install NVM"
  fi
}

# -----------------------------------------------------------------------------

main
break_line
