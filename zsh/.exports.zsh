#!/usr/bin/env zsh

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# SDK Man
export SDKMAN_DIR="/home/marcelohmdias/.sdkman"
[[ -s "/home/marcelohmdias/.sdkman/bin/sdkman-init.sh" ]] && source "/home/marcelohmdias/.sdkman/bin/sdkman-init.sh"

# Node Env
export NODE_ENV='development'
