#!/usr/bin/env bash

# STATUS UPDATE INTERVAL
set -g status-interval 1

# ENABLING MOUSE AND ALLOWING IT TO SELECT PANE
set -g mouse on
bind -n WheelUpPane if-shell -F -t = "#{mouse_any_flag}" "send-keys -M" "if -Ft= '#{pane_in_mode}' 'send-keys -M' 'copy-mode -e; send-keys -M'"

# SETTING DELAY TO AVOID INTERFERING WITH VIM
set -sg escape-time 1

# Changing indexing, base 1
set-option -g base-index 1
setw -g pane-base-index 1
set-option -g renumber-windows on

# SCROLLBACK BUFFER N LINES
set -g history-limit 10000

# DEFINE VI MODE
setw -g mode-keys vi

## Create bindings
bind-key -T copy-mode-vi 'v' send -X begin-selection
bind-key -T copy-mode-vi 'V' send -X select-line
bind-key -T copy-mode-vi 'r' send -X rectangle-toggle

## Enable copy to system's clipboard
bind-key -T copy-mode-vi 'y' send -X copy-pipe-and-cancel "xclip -in -selection clipboard"

