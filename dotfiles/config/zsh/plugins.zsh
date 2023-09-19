#!/bin/bash

function load() {
  local dir="$1"
  for lib in $dir/*; do
    local p_name=$(basename $lib)
    local p_file="$lib/$p_name.plugin.zsh"
    local p_completion="$lib/_$p_name"

    if [[ -f $p_file ]]; then
      plug "$p_file"
    elif [[ -f $p_completion ]]; then
      fpath=($lib $fpath)
    else
      echo "❌ Plugin $p_name not loaded"
    fi
  done
}

# Plugins
plug "zdharma-continuum/fast-syntax-highlighting"
plug "zsh-users/zsh-autosuggestions"
plug "zsh-users/zsh-completions"
plug "zsh-users/zsh-history-substring-search"
plug "zap-zsh/supercharge"
plug "zap-zsh/completions"
plug "wintermi/zsh-bob"
plug "wintermi/zsh-fnm"
plug "wintermi/zsh-lsd"
plug "wintermi/zsh-golang"
plug "wintermi/zsh-rust"
plug "marlonrichert/zsh-hist"
plug "hlissner/zsh-autopair"
plug "MichaelAquilina/zsh-you-should-use"
plug "jscutlery/nx-completion"

if [[ "$OS_RELEASE" == "darwin" ]]; then
  plug "wintermi/zsh-brew"
fi

# Theme
plug "romkatv/powerlevel10k"

load "$ZPLUGINS/omz"
load "$ZPLUGINS/custom"
