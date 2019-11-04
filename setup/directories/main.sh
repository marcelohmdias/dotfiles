#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" && . "./../utils.sh"

main() {
  mkd "$HOME/.config/nvim"
  mkd "$HOME/.config/terminator"
  mkd "$HOME/.fonts"
  mkd "$HOME/.psensor"
  mkd "$HOME/.tmux/plugins"
  mkd "$HOME/.config/nvim/autoload"
  mkd "$HOME/.config/tilix/schemes"
}

print_msg_info "Create directories."
main
