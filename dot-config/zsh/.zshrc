#!/bin/bash

# ░▀▀█░█▀▀░█░█
# ░▄▀░░▀▀█░█▀█
# ░▀▀▀░▀▀▀░▀░▀
#
# Z shell - Interactive interpreter for shell scripting.
# https://github.com/zsh-users/zsh

[[ -f "$ZDOTDIR/exports.zsh" ]] && source "$ZDOTDIR/exports.zsh"

# Show OS info
[[ "$TERM_PROGRAM" != "vscode" && "$TERM_PROGRAM" != "zed" ]] && fastfetch

# Init Zap ZSH
[[ -f "$XDG_DATA_HOME/zap/zap.zsh" ]] && source "$XDG_DATA_HOME/zap/zap.zsh"

plug "$ZDOTDIR/utils.zsh"

# Load config
plug "$ZDOTDIR/plugins.zsh"
plug "$ZDOTDIR/aliases.zsh"
plug "$ZDOTDIR/keybindings.zsh"

export HISTSIZE=10000
export SAVEHIST=10000
export HISTFILE="$HOME/.zsh_history"

setopt SHARE_HISTORY             # Share history between all sessions.

for widget in $ZDOTDIR/functions/*; do
  autoload -Uz ${widget:t}
  zle -N ${widget:t}
done

typeset -TUx FPATH fpath
fpath=("$ZDOTDIR/functions" "${fpath[@]}")
fpath=("$ZCOMP_DIR" $fpath)

# Load and initialise completion system
autoload -Uz compinit
compinit -d "$ZDOTDIR/.zcompdump"
