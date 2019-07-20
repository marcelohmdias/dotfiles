#!/usr/bin/env bash

set -g @tpm_plugins '                   \
  tmux-plugins/tpm                      \
  tmux-plugins/tmux-open                \
  tmux-plugins/tmux-prefix-highlight    \
  tmux-plugins/tmux-sidebar             \
'

if "test ! -d ~/.tmux/plugins/tpm" \
   "run 'git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm'"

run '~/.tmux/plugins/tpm/tpm'

