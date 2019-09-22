#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" && . "./../utils.sh"

# -----------------------------------------------------------------------------

main() {
  print_msg_sub_info "ColorLS Tools"

  install_package "ruby" "Ruby Lang"
  install_package "ruby-dev" "Compiling Extension"
  install_package "ruby-colorize" "Ruby gem for Colorizing"

  install_package "libncurses5-dev" "NCURSES Libraries"
  install_package "libtinfo-dev" "Terminfo Library"

  if ! cmd_exists "colorls"; then
    execute "sudo gem install --quiet --silent colorls" "ColorLS"
  else
    print_msg_success "Instaled ColorLS"
  fi
}

# -----------------------------------------------------------------------------

main
break_line
