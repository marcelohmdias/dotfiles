#!/usr/bin/env bash

set -g default-shell  "/bin/zsh"
set -g default-terminal "xterm-256color"
set -g terminal-overrides ",xterm-256color:Tc"

set -g base-index 1               # start indexing windows at 1
set -g detach-on-destroy off      # don't exit from tmux when closing a session
set -g escape-time 0              # zero-out escape time delay
set -g history-limit 50000        # increase history size
set -g mode-keys vi               # enable vi mode
set -g mouse on                   # enable mouse support
set -g pane-base-index 1          # start indexing pane at 1
set -g renumber-windows on        # renumber all windows when any window is closed
set -g set-clipboard on           # use system clipboard
set -g status on                  # enable status bar
set -g status-interval 5          # update the status bar every 5 seconds
set -g status-position top        # show bar at the top

# ENABLING MOUSE AND ALLOWING IT TO SELECT PANE
bind -n WheelUpPane if-shell -F -t = "#{mouse_any_flag}" "send-keys -M" "if -Ft= '#{pane_in_mode}' 'send-keys -M' 'copy-mode -e; send-keys -M'"

# Remap the prefix B to A
unbind C-b
set -g prefix C-a

# Add keybinding to reload .tmux file
bind r source-file ~/.tmux.conf \; display ' 󰚰 Reloaded...'

## Create bindings
bind-key -T copy-mode-vi 'v' send -X begin-selection
bind-key -T copy-mode-vi 'V' send -X select-line
bind-key -T copy-mode-vi 'r' send -X rectangle-toggle

## Enable copy to system's clipboard
bind-key -T copy-mode-vi 'y' send -X copy-pipe-and-cancel "xclip -in -selection clipboard"

# Send prefix to other applications
bind C-a send-prefix

# Remap keybindings to split panes
unbind '"'
unbind %
bind \\ split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"

# Remap clock mode
unbind t
bind T clock-mode

# Remap next and previous keybindings window
unbind n
bind N next-window
unbind p
bind P previous-window

# Remap keybindings to new window
unbind c
bind n new-window -c '#{pane_current_path}'
bind-key x kill-pane

# Rezise panels
bind -r H resize-pane -L 5
bind -r J resize-pane -D 5
bind -r K resize-pane -U 5
bind -r L resize-pane -R 5

set -g @t-bind 't'
set -g @tmux-nerd-font-window-name-shell-icon ''
set -g @tmux-nerd-font-window-name-show-name true

set -g @plugin 'catppuccin/tmux'
set -g @plugin 'christoomey/vim-tmux-navigator'
set -g @plugin 'joshmedeski/t-smart-tmux-session-manager'
set -g @plugin 'joshmedeski/tmux-nerd-font-window-name'
set -g @plugin 'tmux-plugins/tpm'

set -g @catppuccin_flavour 'frappe'

set -g @catppuccin_window_current_color "#68bce7"
set -g @catppuccin_window_current_fill "number"
set -g @catppuccin_window_current_text "#W"

set -g @catppuccin_window_default_color "#a9d4d6"
set -g @catppuccin_window_default_fill "number"
set -g @catppuccin_window_default_text "#W"

set -g @catppuccin_status_modules_right "dir_name session host indicator"

set -g @catppuccin_status_left_separator  "█"
set -g @catppuccin_status_right_separator "█"

set -g @catppuccin_host_icon "󰒋"
set -g @catppuccin_host_color "#ca9ee6"
set -g @catppuccin_session_icon ""
set -g @catppuccin_session_color "#a5d4a7"

# Bootstrap tpm
if "test ! -d ~/.tmux/plugins/tpm" \
   "run 'git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm && ~/.tmux/plugins/tpm/bin/install_plugins'"

# Init tpm
run "$HOME/.tmux/plugins/tpm/tpm"
