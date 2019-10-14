#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" && . "./../utils.sh"

# ------------------------------------------------------------------------------

main() {
  print_msg_sub_info "Generating ZSH file config"

  if [ -f "$HOME/.zshrc" ]; then
    print_msg_success "File '.zshrc' created"
  else
    printf \
      "#!/usr/bin/env zsh\n\n[ -f ~/.custom/zsh/.init.zsh ] && source ~/.custom/zsh/.init.zsh" \
      >> "$HOME/.zshrc"
      
    print_msg_success "Create file '.zshrc'"
  fi
}

# ------------------------------------------------------------------------------

main
break_line
