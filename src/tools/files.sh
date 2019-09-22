#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
  && . "./../utils.sh" \
  && . "./../file_tools.sh"

# -----------------------------------------------------------------------------

main() {

  plug="https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"

  print_msg_sub_info "App Files Config"

  if [ -f "$HOME/.config/nvim/init.vim" ]; then
    print_msg_success "File 'init.vim' created"
  else
    nvim_config
  fi

  if [ -f "$HOME/.tmux.conf" ]; then
    print_msg_success "File '.tmux.conf' created"
  else
    tmux_config
  fi

  if [ -f "$HOME/.zshrc" ]; then
    print_msg_success "File '.zshrc' created"
  else
    zsh_config
  fi

  if [ -f "$HOME/.tmux/plugins/tpm/tpm" ]; then
    print_msg_success "Tmux TPM Installed"
  else
    execute "git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm &> /dev/null" "Install Tmux TPM"
  fi

  if [ -f "$HOME/.local/share/nvim/site/autoload/plug.vim" ]; then
    print_msg_success "Vim Plug Installed"
  else
    execute "wget -q $plug -P $HOME/.local/share/nvim/site/autoload &> /dev/null" "Install Vim Plug"
  fi

  chsh -s $(which zsh)
  sudo chsh -s $(which zsh)
}

# -----------------------------------------------------------------------------

main
break_line
