#!/usr/bin/env zsh

# Prefix Highlight
set -g @prefix_highlight_fg colour015
set -g @prefix_highlight_bg colour004
set -g @prefix_highlight_show_copy_mode 'on'
set -g @prefix_highlight_copy_prompt '^C'
set -g @prefix_highlight_copy_mode_attr 'fg=colour015,bg=colour005'

# Sidebar
set -g @treemux-tree-nvim-init-file '~/.tmux/plugins/treemux/configs/treemux_init.lua'
set -g @treemux-tree-width '60'

# Extrakto
set -g @extrakto_key "p"
set -g @extrakto_split_direction v
set -g @extrakto_split_size "10"
set -g @extrakto_copy_key "tab"
set -g @extrakto_insert_key "enter"
set -g @extrakto_clip_tool "xclip -in -selection clipboard"
