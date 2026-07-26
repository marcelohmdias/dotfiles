#!/bin/bash

function load() {
  local dir="$1"
  for lib in $dir/*; do
    local p_name=$(basename $lib)
    local p_file="$lib/$p_name.plugin.zsh"

    if [[ -f $p_file ]]; then
      plug "$p_file"
    else
      echo "❌ Plugin $p_name not loaded"
    fi
  done
}
