#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" && . "./../utils.sh"

# ------------------------------------------------------------------------------

main() {
  print_msg_sub_info "Generating Tmux file config"

  if [ -f "$HOME/.tmux.conf" ]; then
    print_msg_success "File '.tmux.conf' created"
  else
    printf "#!/usr/bin/env bash\n\nsource-file ~/.custom/tmux/init.tmux" \
      >> "$HOME/.tmux.conf"
      
    print_msg_success "Create file '.tmux.conf'"
  fi

  if [ -f "$HOME/.tmux/plugins/tpm/tpm" ]; then
    print_msg_success "Tmux TPM Installed"
  else
    execute "git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm &> /dev/null" "Install Tmux TPM"
  fi
}

# ------------------------------------------------------------------------------

main
break_line
