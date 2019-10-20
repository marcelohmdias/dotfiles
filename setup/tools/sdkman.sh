#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" && . "./../utils.sh"

# -----------------------------------------------------------------------------

main() {
  local -a url="https://get.sdkman.io"

  print_msg_sub_info "SDKMan"

  if cmd_exists "sdk"; then
    print_msg_success "SDKMan Installed"
  else
    execute "wget -qO- $url | bash &> /dev/null" "Install SDKMan"

    source "$HOME/.sdkman/bin/sdkman-init.sh"
  fi
}

# -----------------------------------------------------------------------------

main
break_line
