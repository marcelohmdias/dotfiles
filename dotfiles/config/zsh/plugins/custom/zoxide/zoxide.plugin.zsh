#!/usr/bin/env zsh

if ! command -v zoxide &> /dev/null; then
  echo '❌ Zoxide not found, please install it from https://github.com/ajeetdsouza/zoxide'
else
  eval "$(zoxide init zsh)"
fi
