#!/usr/bin/env zsh

set -g @tpm_plugins '                    \
  tmux-plugins/tpm                       \
  tmux-plugins/tmux-open                 \
  tmux-plugins/tmux-prefix-highlight     \
  kiyoon/treemux                         \
  laktak/extrakto                        \
  joshmedeski/tmux-nerd-font-window-name \
'

if "test ! -d ~/.tmux/plugins/tpm" \
   "run 'git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm'"

run '~/.tmux/plugins/tpm/tpm'

