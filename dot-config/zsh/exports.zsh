#!/bin/bash

export OS_RELEASE="$(uname | tr '[:upper:]' '[:lower:]')"

case $OS_RELEASE in
darwin)
  export OS_DISTRO="mac"
  ;;
linux)
  export OS_DISTRO="$(grep -P '^ID=' /etc/os-release | cut -d '=' -f 2 | xargs)"
  ;;
esac

# Applications preset
export ATUIN_NOBIND="true"

export BAT_THEME="Catppuccin-frappe"

export EZA_PARAMS=('--git' '--icons' '--group' '--group-directories-first' '--time-style=long-iso' '--color-scale=all')

export FORCE_COLOR=true

export FZF_DEFAULT_OPTS=$(echo " \
  --ansi \
  --bind 'btab:up,tab:down' \
  --border 'rounded' \
  --color 'bg+:-1,bg:-1,spinner:#f2d5cf,hl:#e78284' \
  --color 'fg:#b5bfe2,header:#8caaee,info:#ca9ee6,pointer:#8caaee' \
  --color 'border:#c6d0f5,label:#c6d0f5,scrollbar:#949cbb' \
  --color 'marker:#f2d5cf,fg+:#c6d0f5,prompt:#ca9ee6,hl+:#e78284' \
  --height '50%' \
  --info 'inline-right' \
  --margin '0' \
  --padding '0' \
  --pointer '▶' \
  --prompt '  ' \
  --reverse \
  --tmux '60%' \
")

export FZF_ALT_C_OPTS=$(echo " \
  --border-label '  Last Commands ' \
  --preview 'tree -C {}' \
  --tac \
")

export FZF_CTRL_R_OPTS=$(echo " \
  --bind 'ctrl-/:toggle-preview' \
  --bind 'ctrl-y:execute-silent(echo -n {2..} | xclip -selection clipboard)+abort' \
  --border-label '  Last Commands ' \
  --header '󰅍 Press: ^y copy command into clipboard \n\n' \
  --preview 'echo {}' \
  --preview-window 'down:3:hidden:wrap' \
")

export FZF_CTRL_T_OPTS=$(echo " \
  --bind 'ctrl-/:change-preview-window(down|hidden|)' \
  --border-label '  Last Commands ' \
  --header '󰆏 Select to copy \n\n' \
  --preview 'bat -n --color=always {} --theme=Catppuccin-frappe' \
  --tac \
")

export GIT_SSH_COMMAND='ssh -o "HostName=ssh.github.com" -o "Port=443" -o "IdentityFile=~/.ssh/id_rsa" -o "User=git"'

export GLAMOUR_STYLE="$HOME/.config/glamour/frappe.json"

export NPM_CONFIG_USERCONFIG="$HOME/.config/npm/.npmrc"

export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"

export TERM=xterm-256color

export VI_MODE_ESC_INSERT="jk"

export YSU_HARDCORE=1

# PATH config
export PATH="$PATH:$HOME/.config/zsh/bin"
export PATH="$PATH:$HOME/.local/bin"
export PATH="$PATH:$HOME/.local/share/flatpak/exports/bin"
