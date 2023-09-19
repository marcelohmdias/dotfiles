#!/usr/bin/env zsh

if ! command -v bun &> /dev/null; then
  echo '❌ Bun not found, please install it from https://bun.sh/'
else
  fpath=($BUN_DIR $fpath)
fi
