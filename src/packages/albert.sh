#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" && . "./../utils.sh"

# -----------------------------------------------------------------------------

main() {
  local -a version="$(get_release)"
  local -a key="https://build.opensuse.org/projects/home:manuelschneid3r/public_key"
  local -a repository="http://download.opensuse.org/repositories/home:/manuelschneid3r/xUbuntu_$version/"
  local -a file="/etc/apt/sources.list.d/home:manuelschneid3r.list"

  print_msg_sub_info "Albert Launcher"

  if package_is_installed "albert"; then
    print_msg_success "Albert Installed"
  else
    add_key "$key"

    echo "deb $repository /" | sudo tee "$file" &> /dev/null

    update_apt

    install_package "albert" "Install Albert"
  fi
}

# -----------------------------------------------------------------------------

main
break_line
