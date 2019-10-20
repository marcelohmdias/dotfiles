#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" && . "./../utils.sh"

# ------------------------------------------------------------------------------

main() {
  print_msg_sub_info "Generating NVim file config"

  plug="https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"

  if [ -f "$HOME/.config/nvim/init.vim" ]; then
    print_msg_success "File 'init.vim' created"
  else
    printf '%s\n' \
      "source $HOME/.custom/nvim/init.vim" \
      >> "$HOME/.config/nvim/init.vim"
      
    print_msg_success "Create file 'init.vim'"
  fi

  if [ -f "$HOME/.local/share/nvim/site/autoload/plug.vim" ]; then
    print_msg_success "Vim Plug Installed"
  else
    execute "wget -q $plug -P $HOME/.local/share/nvim/site/autoload &> /dev/null" "Install Vim Plug"
  fi
}

# ------------------------------------------------------------------------------

main
break_line
