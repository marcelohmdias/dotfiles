#!/usr/bin/env zsh

if [[ ! -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]]; then
  echo 'Sdkman not found, please install it from https://sdkman.io/'
else
  source "$SDKMAN_DIR/bin/sdkman-init.sh"
fi
