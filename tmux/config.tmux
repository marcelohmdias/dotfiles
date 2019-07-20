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

