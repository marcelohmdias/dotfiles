#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" && . "./../utils.sh"

# -----------------------------------------------------------------------------

print_msg_info "Install Packages."

./config.sh
./tools.sh
./themes.sh
./wine.sh
./packages.sh
./debs.sh
./snaps.sh
./albert.sh
./browsers.sh
./sublime_merge.sh
./typora.sh
./vs_code.sh
./kitematic.sh
