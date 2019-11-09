#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" && . "./../utils.sh"

# -----------------------------------------------------------------------------

main() {
  print_msg_sub_info "Flatpak Config"

  if cmd_exists "flatpak"; then
    print_msg_success "Flatpak Installed"
  else
    install_package "flatpak" "Flatpak Store"
    install_package "gnome-software-plugin-flatpak" "Plugin for Ubuntu Store"
    execute "flatpak remote-add --if-not-exists flathub flathub https://flathub.org/repo/flathub.flatpakrepo" "Flatpak Repository"
  fi
}

# -----------------------------------------------------------------------------

main
break_line
