#!/bin/bash

export ZPLUGINS="$ZDOTDIR/plugins"

export OS_RELEASE="$(uname | tr '[:upper:]' '[:lower:]')"

case $OS_RELEASE in
darwin)
  export OS_DISTRO="mac"
  ;;
linux)
  export OS_DISTRO="$(grep -P '^ID=' /etc/os-release | cut -d '=' -f 2 | xargs)"
  ;;
esac

export TERM=xterm-256color

export FZF_DEFAULT_OPTS='
--bind btab:up,tab:down
--border
--color=bg+:#303446,bg:#303446,spinner:#f2d5cf,hl:#e78284
--color=fg:#c6d0f5,header:#8caaee,info:#ca9ee6,pointer:#8caaee
--color=marker:#f2d5cf,fg+:#c6d0f5,prompt:#ca9ee6,hl+:#e78284
--height=60%
--info=hidden
--margin=1
--padding=1
--pointer=▶
--prompt=❯
--reverse'
export FZF_TMUX_OPTS="-p 80%,60%"
export FZF_ALT_C_OPTS="--tac --preview 'tree -C {}'"
export FZF_CTRL_R_OPTS=" \
--bind 'ctrl-/:toggle-preview' \
--bind 'ctrl-y:execute-silent(echo -n {2..} | xclip -selection clipboard)+abort' \
--header='󱃔 Press CTRL-Y to copy command into clipboard' \
--preview 'echo {}' \
--preview-window down:3:hidden:wrap"
export FZF_CTRL_T_OPTS=" \
--bind 'ctrl-/:change-preview-window(down|hidden|)' \
--header '󰆏 Select to copy' \
--preview 'bat -n --color=always {} --theme=Catppuccin-frappe' \
--tac"

export FORCE_COLOR=true

export NODE_ENV="development"

export BAT_THEME="Catppuccin-frappe"

export GLAMOUR_STYLE="$HOME/.config/glamour/frappe.json"

export YSU_HARDCORE=1

# Global dirs
export BUN_DIR="$HOME/.bun"
export FZF_DIR="$HOME/.fzf"
export GO_DIR="$HOME/.go"
export NVM_DIR="$HOME/.nvm"
export SDKMAN_DIR="$HOME/.sdkman"

export GOPATH="$GO_DIR"
export GOROOT="$HOME/.local/share/golang"

# FPATH config
export fpath=("$ZDOTDIR/functions" "${fpath[@]}")

# PATH config
export PATH="$GO_DIR/bin:$PATH"
export PATH="$BUN_DIR/bin:$PATH"
export PATH="$HOME/.local/lib/go/bin:$PATH"
export PATH="$HOME/.local/share/flatpak/exports/bin:$PATH"
export PATH="$HOME/.tmux/plugins/t-smart-tmux-session-manager/bin:$PATH"

source "$HOME/.cargo/env"
