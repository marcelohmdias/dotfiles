#!/usr/bin/env zsh

# Reload ZSH config
alias reload='clear && echo "ZSH config reloaded from ~/.zshrc...\n" && . ~/.zshrc'

# Install .deb files
alias deb='sudo dpkg -i --force-depends'

# List directories with report
alias ls="colorls -a --sd --report --dark"

# RAM Consumption Report
alias ram='free -h'
alias ramf='sudo sysctl -w vm.drop_caches=3'

# Install and Uninstall Command
alias install='sudo apt-get install -y'
alias uninstall='sudo apt-get remove --purge -y'

# Ubuntu update command
alias update='sudo apt-get -y update && sudo apt-get -y upgrade && sudo apt-get -y autoclean && sudo apt-get -y autoremove'

# Repository management
alias add='sudo add-apt-repository -y'
alias remove='sudo apt-add-repository -r -y'

# Python Virtual ENV command
alias managepy='python"$VIRTUAL_ENV/manage.py'

# Global Node libs
alias npm-install='npm i -g \
  @nestjs/cli \
  @quasar/cli \
  @storybook/cli \
  @vue/cli \
  create-nuxt-app \
  commitizen \
  eslint \
  gitignore \
  gitmoji-cli \
  knex \
  mongo-hacker \
  nodemon \
  npm@latest \
	pm2 \
  trash-cli \
  typescript \
  yarn'

# Edit Git config files
alias git-config='git config --global -e'

# Apps command
alias trmdf="sudo update-alternatives --config x-terminal-emulator"
alias trmlc="dconf dump /com/gexperts/Tilix/ < $HOME/.custom/files/tilix.dconf"
alias trmsc="dconf dump /com/gexperts/Tilix/ > $HOME/.custom/files/tilix.dconf"

alias vi=nvim
