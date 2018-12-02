#!/usr/bin/env bash

# Run Plugins
source-file ~/.custom/tmux/plugins.tmux

# Globals Configs
source-file ~/.custom/tmux/config.tmux

# Define Keybindings
source-file ~/.custom/tmux/keybindings.tmux

# Customize Theme
source-file ~/.custom/tmux/themes.tmux

# Initialize TMUX plugin manager
run -b '~/.tmux/plugins/tpm/tpm'
