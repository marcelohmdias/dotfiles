#!/bin/bash

zle     -N              tsm

bindkey -M  emacs '^k'  tsm
bindkey -M  vicmd '^k'  tsm
bindkey -M  viins '^k'  tsm

bindkey -s '^x' '^ureload\n'          # Reload ZSH config
bindkey '^[l' clear-screen            # Clear term values
bindkey '^[r' atuin-search            # Clear term values
bindkey '^[^A' tmux-toggle-bar        # Toggle visibility of the Tmux bar
bindkey '^[^S' tmux-toggle-position   # Toggle position of the Tmux pane
