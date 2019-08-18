firefox_icon() {
  sudo touch /usr/share/applications/firefox-developer.desktop && printf \
      "[Desktop Entry]\nName=Firefox Developer\nGenericName=Firefox Developer Edition\nExec=/usr/local/bin/firefox\nTerminal=false\nIcon=firefox-developer-edition\nType=Application\nCategories=Application;Network;X-Developer;\nComment=Firefox Developer Edition Web Browser" \
      | sudo tee /usr/share/applications/firefox-developer.desktop &> /dev/null
}

nvim_config() {
  printf "source $HOME/.custom/nvim/init.vim" >> "$HOME/.config/nvim/init.vim"
  print_msg_success "Create file 'init.vim'"
}

tmux_config() {
  printf "#!/usr/bin/env bash\n\nsource-file ~/.custom/tmux/init.tmux" >> "$HOME/.tmux.conf"
  print_msg_success "Create file '.tmux.conf'"
}

zsh_config() {
  printf "#!/usr/bin/env zsh\n\n[ -f ~/.custom/zsh/.init.zsh ] && source ~/.custom/zsh/.init.zsh" >> "$HOME/.zshrc"
  print_msg_success "Create file '.zshrc'"
}
