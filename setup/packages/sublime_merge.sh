#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" && . "./../utils.sh"

# ------------------------------------------------------------------------------

main() {
  local -a key="https://download.sublimetext.com/sublimehq-pub.gpg"
  local -a repository="https://download.sublimetext.com/"
  local -a file="/etc/apt/sources.list.d/sublime-text.list"

  print_msg_sub_info "Sublime Merge"

  if package_is_installed "sublime-merge"; then
    print_msg_success "Sublime Merge Installed"
  else
    add_key "$key"

    echo "deb $repository apt/stable/" | sudo tee "$file" &> /dev/null

    update_apt

    install_package "sublime-merge" "Install Sublime Merge"
  fi
}

# ------------------------------------------------------------------------------

main
break_line
