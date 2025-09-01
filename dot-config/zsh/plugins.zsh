#!/bin/bash

# Plugins

[[ "$OS_RELEASE" = "darwin" ]] && plug "wintermi/zsh-brew"

plug "wintermi/zsh-mise"
plug "Aloxaf/fzf-tab"
plug "zdharma-continuum/fast-syntax-highlighting"
plug "zsh-users/zsh-autosuggestions"
plug "zsh-users/zsh-completions"
plug "zsh-users/zsh-history-substring-search"
plug "zap-zsh/supercharge"
plug "zap-zsh/completions"
plug "zap-zsh/vim"
plug "hlissner/zsh-autopair"
plug "marlonrichert/zsh-hist"
plug "MichaelAquilina/zsh-you-should-use"
plug "marcelohmdias/zsh-atuin"
plug "marcelohmdias/zsh-bun"
plug "marcelohmdias/zsh-deno"
plug "marcelohmdias/zsh-fzf"
plug "marcelohmdias/zsh-gh"
plug "marcelohmdias/zsh-just"
plug "marcelohmdias/zsh-rust"
plug "wintermi/zsh-bob"
plug "sdiebolt/zsh-ssh-agent"

# Custom plugins
load "$ZDOTDIR/plugins"

# Theme
type starship_zle-keymap-select >/dev/null || { plug "wintermi/zsh-starship" }

[[ $+commands[zoxide] ]] && eval "$(zoxide init zsh)"

[[ ! -z "$FZF_TAB_HOME" ]] && zstyle ':completion:*:*:*:*:descriptions' format ''

zstyle ':fzf-tab:*' fzf-flags \
  --ansi \
  --bind 'btab:up,tab:down' \
  --border 'rounded' \
  --color 'bg+:-1,bg:-1,spinner:#f2d5cf,hl:#e78284' \
  --color 'fg:#b5bfe2,header:#8caaee,info:#ca9ee6,pointer:#8caaee' \
  --color 'border:#c6d0f5,label:#c6d0f5,scrollbar:#949cbb' \
  --color 'marker:#f2d5cf,fg+:#c6d0f5,prompt:#ca9ee6,hl+:#e78284' \
  --height '40%' \
  --info 'inline-right' \
  --margin '0' \
  --padding '0' \
  --pointer '▶' \
  --prompt '  ' \
  --reverse

