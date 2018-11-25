#!/usr/bin/env bash

# Add keybinding to reload .tmux file
bind r source-file ~/.tmux.conf \; display ' ﮮ  Reloaded...'

# Remap the prefix B to A
unbind C-b
set -g prefix C-a
bind C-a send-prefix

# Send prefix to other applications
bind C-a send-prefix

# Remap keybindings to split panes
unbind '"'
unbind %
bind | split-window -h
bind - split-window -v

# Remap next and previous keybindings window
unbind n
bind N next-window
unbind p
bind P previous-window

# Remap keybindings to new window
unbind c
bind n new-window
