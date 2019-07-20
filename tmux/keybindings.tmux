#!/usr/bin/env bash

# Remap the prefix B to A
unbind C-b
set -g prefix C-a

# Send prefix to other applications
bind C-a send-prefix

# Add keybinding to reload .tmux file
bind r source-file ~/.tmux.conf \; display ' ﮮ  Reloaded...'

# Remap keybindings to split panes
unbind '"'
unbind %
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"

# Remap next and previous keybindings window
unbind n
bind N next-window
unbind p
bind P previous-window

# Remap keybindings to new window
unbind c
bind n new-window
