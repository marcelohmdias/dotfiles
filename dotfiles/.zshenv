setopt no_global_rcs

export XDG_CACHE_HOME="$HOME/.cache"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_RUNTIME_DIR="/tmp"
export XDG_STATE_HOME="$HOME/.local/state"

export ZDOTDIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"
