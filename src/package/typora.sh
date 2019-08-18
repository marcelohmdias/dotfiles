#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" && . "./../utils.sh"

# -----------------------------------------------------------------------------

main() {
  local -a key="https://typora.io/linux/public-key.asc"
  local -a repository="https://typora.io/linux ./"
  local -a file="/etc/apt/sources.list.d/home:manuelschneid3r.list"

  print_msg_sub_info "Typora"

  if package_is_installed "typora"; then
    print_msg_success "Typora Installed"
  else
    add_key "$key"
    add_ppa_deb "$repository" "Add Repository"

    update_apt

    install_package "typora" "Typora"
  fi
}

# -----------------------------------------------------------------------------

main
break_line
