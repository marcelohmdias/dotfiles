#!/usr/bin/env zsh

# settings 256 colors
set -g default-terminal 'screen-256color'

# STATUS BAR CONFIG
set -g status-fg colour250
set -g status-bg colour233

# LEFT SIDE OF STATUS BAR
set -g status-left-style bg=colour235
set -g status-left-style fg=colour245
set -g status-left-length 40
set -g status-left '#{prefix_highlight}#{prefix_highlight}#[fg=colour015,bg=colour000,bold]   #S #[fg=colour000,bg=colour008,nobold]#[fg=colour015,bg=colour008] #(whoami) #[fg=colour008,bg=colour015]#[fg=colour000,bg=colour015] #I:#P #[fg=colour015,bg=colour233,nobold]'

# RIGHT SIDE OF STATUS BAR
set -g status-right-style bg=colour233,fg=colour245
set -g status-right-length 150
set -g status-right '#[fg=colour007,bg=colour233]#[fg=colour000,bg=colour007] %H:%M  #[fg=colour008,bg=colour007] #[fg=colour015,bg=colour008] %d-%b-%y  #[fg=colour000,bg=colour008] #[fg=colour007,bg=colour000,bold] #H   '

# WINDOW STATUS CONFIG
set -g window-status-style bg=colour000,fg=colour015
set -g window-status-format '   #I: #W '

# CURRENT WINDOW STATUS
set -g window-status-current-style bg=colour004,fg=colour015
set -g window-status-current-format '   #I: #W '

# Window with activity status
set -g window-status-activity-style bg=colour31,fg=colour233 # a bug in tmux

# TITLE RENAME
set-option -g set-titles on
set-option -g set-titles-string '#T'
set -g allow-rename on

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
set -g pane-border-style bg=colour000,fg=colour015
set -g pane-active-border-style bg=colour000,fg=colour015

# Pane number indicator
set -g display-panes-colour colour233
set -g display-panes-active-colour colour245

# Clock mode
set -g clock-mode-colour colour24
set -g clock-mode-style 24

# Message
set -g message-style bg=colour002,fg=colour015

# Command message
set -g message-command-style bg=colour233,fg=colour000

# Mode
set -g mode-style bg=colour24,fg=colour231
