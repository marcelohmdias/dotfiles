#!/usr/bin/env zsh

if ! command -v git &> /dev/null; then
  echo '❌ Git not found, please install it from https://git-scm.com/'
else
  fpath=("$ZPLUGINS/custom/git" $fpath)
fi
