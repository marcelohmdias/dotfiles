#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" && . "./../utils.sh"

# ------------------------------------------------------------------------------

print_msg_info "Setting preferences."

./nvim.sh
./tmux.sh
./zsh.sh

dconf load /com/gexperts/Tilix/ < $HOME/.custom/files/tilix.dconf

chsh -s $(which zsh)
sudo chsh -s $(which zsh)