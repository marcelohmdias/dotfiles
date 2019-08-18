#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" && . "./../utils.sh"

# -----------------------------------------------------------------------------

main() {
  print_msg_sub_info "Terminal Tools"

  install_package "curl"                "cURL"
  install_package "fzf"                 "Fuzzy Finder"
  install_package "git"                 "Git"
  install_package "htop"                "Htop"
  install_package "neofetch"            "Neofetch"
  install_package "neovim"              "Neovim"
  install_package "silversearcher-ag"   "Silver Searcher"
  install_package "tmux"                "Tmux"
  install_package "tree"                "Tree"
  install_package "zsh"                 "ZSH"
}

# -----------------------------------------------------------------------------

main
break_line
