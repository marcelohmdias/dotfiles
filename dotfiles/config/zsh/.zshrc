#!/bin/bash

# Show OS info
if [[ "$TERM_PROGRAM" != "vscode" ]]; then
  neofetch
fi

# Load Environments and Path config
source "$ZDOTDIR/env.zsh"

# Pl10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Init Zap ZSH
if [[ -f "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh" ]]; then
  source "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh"
fi

# Load config
plug "$ZDOTDIR/.p10k.zsh"
plug "$ZDOTDIR/plugins.zsh"
plug "$ZDOTDIR/aliases.zsh"
plug "$ZDOTDIR/functions.zsh"
plug "$ZDOTDIR/keybindings.zsh"
plug "$ZDOTDIR/opts.zsh"

# Load and initialise completion system
autoload -Uz compinit
compinit

# To customize prompt, run `p10k configure` or edit ~/.config/zsh/.p10k.zsh.
[[ ! -f ~/.config/zsh/.p10k.zsh ]] || source ~/.config/zsh/.p10k.zsh
