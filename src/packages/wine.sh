#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" && . "./../utils.sh"

# -----------------------------------------------------------------------------

main() {
  local -a name="$(get_codiname)"
  local -a key="https://dl.winehq.org/wine-builds/winehq.key"
  local -a repository="https://dl.winehq.org/wine-builds/ubuntu/ $name main"

  print_msg_sub_info "WineHQ"

  if package_is_installed "winehq-stable"; then
    print_msg_success "WineHQ Installed"
  else
    execute "sudo dpkg --add-architecture i386" "Add 32bit suport"

    add_key "$key"

    add_ppa_deb "$repository" "Wine PPA"

    update_apt

    install_package "winehq-stable wine-stable wine-stable-i386 wine-stable-amd64" "Install WineHQ" "--install-recommends"
  fi
}

# -----------------------------------------------------------------------------

main
break_line
