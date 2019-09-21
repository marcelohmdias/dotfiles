#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" && . "./../utils.sh"

# -----------------------------------------------------------------------------

main() {
  print_msg_sub_info "Apt Packages"

  install_package "gimp"                        "Gimp"
  install_package "gnome-tweak-tool"            "Gnome Tweak Tool"
  install_package "gparted"                     "Gparted"
  install_package "gufw"                        "Firewall Gufw"
  install_package "lutris"                      "Lutris"
  install_package "meld"                        "Meld"
  install_package "menulibre"                   "MenuLibre"
  install_package "playonlinux"                 "PlayOnLinux"
  install_package "piper"                       "Piper"
  install_package "psensor"                     "PSensor"
  install_package "speedcrunch"                 "SpeedCrunch"
  install_package "terminator"                  "Terminator"
  install_package "tilix"                       "Tilix"
  install_package "variety"                     "Variety"
  install_package "vlc"                         "VLC"
  install_package "zeal"                        "Zeal Docs"
}

# -----------------------------------------------------------------------------

main
break_line
