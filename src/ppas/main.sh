#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" && . "./../utils.sh"

# -----------------------------------------------------------------------------

print_msg_info "Add PPAs."

./ppas_apps.sh

./ppas_drivers.sh

./ppas_themes.sh

./ppas_tools.sh

# -----------------------------------------------------------------------------

update_apt
break_line
