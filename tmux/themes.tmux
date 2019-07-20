#!/usr/bin/env bash

# settings 256 colors
set -g default-terminal 'screen-256color'

# STATUS BAR CONFIG
set -g status-fg colour250
set -g status-bg colour233

# LEFT SIDE OF STATUS BAR
set -g status-left-bg colour235
set -g status-left-fg colour245
set -g status-left-length 40
set -g status-left '#{prefix_highlight}#{prefix_highlight}#[fg=colour015,bg=colour000,bold]   #S #[fg=colour000,bg=colour008,nobold]#[fg=colour015,bg=colour008] #(whoami) #[fg=colour008,bg=colour015]#[fg=colour000,bg=colour015] #I:#P #[fg=colour015,bg=colour233,nobold]'

# RIGHT SIDE OF STATUS BAR
set -g status-right-bg colour233
set -g status-right-fg colour245
set -g status-right-length 150
set -g status-right '#[fg=colour007,bg=colour233]#[fg=colour000,bg=colour007] %H:%M  #[fg=colour008,bg=colour007] #[fg=colour015,bg=colour008] %d-%b-%y  #[fg=colour000,bg=colour008] #[fg=colour007,bg=colour000,bold] #H   '

# WINDOW STATUS CONFIG
set -g window-status-bg colour000
set -g window-status-fg colour015
set -g window-status-format '   #I: #W '

# CURRENT WINDOW STATUS
set -g window-status-current-bg colour004
set -g window-status-current-fg colour015
set -g window-status-current-format '   #I: #W '

# Window with activity status
set -g window-status-activity-bg colour31  # fg and bg are flipped here due to
set -g window-status-activity-fg colour233 # a bug in tmux

# STATUS RENAME
setw -g automatic-rename off
set-option -g allow-rename off
set-window-option -g automatic-rename off
setw -g monitor-activity on
set -g visual-activity on

# Window separator
set -g window-status-separator ''

# Window status alignment
set -g status-justify centre

# BORDER CONFIG
set -g pane-border-fg colour015
set -g pane-border-bg colour000
set -g pane-active-border-fg colour015
set -g pane-active-border-bg colour000

# Pane number indicator
set -g display-panes-colour colour233
set -g display-panes-active-colour colour245

# Clock mode
set -g clock-mode-colour colour24
set -g clock-mode-style 24

# Message
set -g message-bg colour002
set -g message-fg colour015

# Command message
set -g message-command-bg colour233
set -g message-command-fg black

# Mode
set -g mode-bg colour24
set -g mode-fg colour231

