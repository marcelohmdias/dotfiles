#!/bin/bash

# CD to back
alias ...='../..'
alias ....='../../..'
alias .....='../../../..'
alias ......='../../../../..'

# Reload ZSH config
alias reload='clear && echo "󰚰 Reloading ZSH...\n" && source $ZDOTDIR/.zshrc'

# Edit Git config files
alias gconf='git config --global -e'

# Bun
alias fkill='bunx --bun fkill-cli'
alias gitignore='bunx --bun gitignore'
alias np='bunx --bun np'
alias npkill='bunx --bun npkill'
alias serve='bunx serve'
alias taze='bunx taze -r -w -I'

case $OS_RELEASE in
darwin)
  # Apps
  alias wez='wezterm'
  ;;
linux)
  # Repository management
  alias add='sudo add-apt-repository -y'
  alias remove='sudo apt-add-repository -r -y'

  # Install .deb files
  alias deb='sudo dpkg -i --force-depends'

  # RAM Consumption Report
  alias ram='free -h'
  alias ramf='sudo sysctl -w vm.drop_caches=3'

  # Nala (apt utils) upgrade command
  alias install='sudo nala install -y'
  alias uninstall='sudo nala remove --purge -y'

  # Apps command
  alias trmdf="sudo update-alternatives --config x-terminal-emulator"

  # Flatpak apps
  alias ff='flatpak run org.fontforge.FontForge'
  alias wez='flatpak run org.wezfurlong.wezterm'

  # Hardware
  alias mxm='setxkbmap -model abnt -layout us -variant intl'
  ;;
esac
