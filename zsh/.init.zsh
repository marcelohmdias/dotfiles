#!/usr/bin/env zsh

export ZSH=$HOME/.oh-my-zsh
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin"

plugins=(
  bgnotify
  command-not-found
  git
  git-extras
  jsontools
  npm
  nvm
  terminitor
  tmux
  yarn
  zsh-256color
  zsh-autosuggestions
  zsh-completions
  zsh_reload
  zsh-syntax-highlighting
)

ZSH_THEME="powerlevel9k/powerlevel9k"
POWERLEVEL9K_MODE="nerdfont-complete"

source $ZSH/oh-my-zsh.sh
source $ZSH/custom/themes/powerlevel9k/powerlevel9k.zsh-theme

[ -f ~/.custom/zsh/.aliases.zsh ] && source ~/.custom/zsh/.aliases.zsh

[ -f ~/.custom/zsh/.exports.zsh ] && source ~/.custom/zsh/.exports.zsh

[ -f ~/.custom/zsh/.functions.zsh ] && source ~/.custom/zsh/.functions.zsh

[ -f ~/.custom/zsh/.themes.zsh ] && source ~/.custom/zsh/.themes.zsh

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

autoload -U compinit && compinit

neofetch
