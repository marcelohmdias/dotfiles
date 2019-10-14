#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" && . "./../utils.sh"

main() {
  local -a DIRECTORIES=(
    "$HOME/.config/nvim"
    "$HOME/.config/terminator"
    "$HOME/.fonts"
    "$HOME/.psensor"
    "$HOME/.tmux/plugins"
    "$HOME/.config/nvim/autoload"
    "$HOME/.config/tilix/schemes"
  )

  for i in "${DIRECTORIES[@]}"; do
    mkd "$i"
  done
}

print_msg_info "Create directories."
main
