#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" && . "./../utils.sh"

# -----------------------------------------------------------------------------

main() {
  declare -r ZSH_DIRECTORY="$HOME/.oh-my-zsh"

  local -a url="https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh"

  local -a theme_fold="$ZSH_DIRECTORY/custom/themes"
  local -a plugin_fold="$ZSH_DIRECTORY/custom/plugins"

  local -a theme_url="https://github.com/bhilburn/powerlevel9k.git"

  local -a color_url="https://github.com/chrissicool/zsh-256color"
  local -a suggestions_url="https://github.com/zsh-users/zsh-autosuggestions"
  local -a completions_url="https://github.com/zsh-users/zsh-completions"
  local -a highlighting_url="https://github.com/zsh-users/zsh-syntax-highlighting.git"

  print_msg_sub_info "Oh My ZSH"

  if [ -d "$ZSH_DIRECTORY" ]; then
    print_msg_success "Oh My ZSH Installed"
  else
    execute "wget -qO- $url | sh" "Install Oh My ZSH"
    break_line

    execute "git clone $theme_url $theme_fold/powerlevel9k &> /dev/null" "Install Powerlevel9k"

    execute "git clone $color_url $plugin_fold/zsh-256color &> /dev/null" "Install 256Color"
    execute "git clone $suggestions_url $plugin_fold/zsh-autosuggestions &> /dev/null" "Install Auto Suggestions"
    execute "git clone $completions_url $plugin_fold/zsh-completions &> /dev/null" "Install Completions"
    execute "git clone $highlighting_url $plugin_fold/zsh-syntax-highlighting &> /dev/null" "Install Syntax Highlighting"

    rm -rf "$HOME/.zshrc"
  fi
}

# -----------------------------------------------------------------------------

main
break_line
