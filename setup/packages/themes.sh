#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" && . "./../utils.sh"

# ------------------------------------------------------------------------------

main() {
  print_msg_sub_info "Theme and Icons"

  install_package "arc-theme" "Arc Theme"

  install_package "flat-remix" "Flat-remix Icon"
  install_package "flat-remix-gnome" "Flat Remix Gnome Theme"
  install_package "flat-remix-gtk" "Flat Remix Gtk Theme"

  install_package "numix-icon-theme" "Numix Icon"
  install_package "numix-gtk-theme" "Numix Theme"

  install_package "paper-icon-theme" "Paper Icon"

  install_package "papirus-icon-theme" "Papirus Icon"
}

# ------------------------------------------------------------------------------

main
break_line
