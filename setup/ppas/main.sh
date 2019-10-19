#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" && . "./../utils.sh"

print_msg_info "Add PPAs."

./ppas_apps.sh
./ppas_themes.sh
./ppas_tools.sh

update_apt
