#!/usr/bin/env zsh

export ZSH=$HOME/.oh-my-zsh

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:$ZSH_CUSTOM/plugins/navi"

plugins=(
  bgnotify
  command-not-found
  docker
  docker-compose
  fzf
  git
  git-extras
  jsontools
  npm
  nvm
  tmux
  yarn
  zsh-256color
  zsh-autosuggestions
  zsh-completions
  zsh-syntax-highlighting
)

# ZSH_THEME="powerlevel10k/powerlevel10k"
ZSH_THEME="powerlevel9k/powerlevel9k"
POWERLEVEL9K_MODE="nerdfont-complete"

source $ZSH/oh-my-zsh.sh

[ -f ~/.custom/zsh/.aliases.zsh ] && source ~/.custom/zsh/.aliases.zsh

[ -f ~/.custom/zsh/.exports.zsh ] && source ~/.custom/zsh/.exports.zsh

[ -f ~/.custom/zsh/.functions.zsh ] && source ~/.custom/zsh/.functions.zsh

[ -f ~/.custom/zsh/.themes.zsh ] && source ~/.custom/zsh/.themes.zsh

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

autoload -U compinit && compinit

nvm use &>/dev/null

neofetch
