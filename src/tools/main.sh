#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" && . "./../utils.sh"

# -----------------------------------------------------------------------------

print_msg_info "Install Packages."

./colorls.sh
./flatpak.sh
./lpass.sh
./nvm.sh
./sdkman.sh
./docker.sh
./zsh.sh
./files.sh
