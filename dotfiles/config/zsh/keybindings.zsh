#!/bin/bash

bindkey -s '^x' '^ureload\n' # Reload config
bindkey "^[l" clear-screen # CLear screen
bindkey "^[^B" tmux-toggle-bar
bindkey "^[^P" tmux-toggle-position
