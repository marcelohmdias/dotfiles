#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" && . "./utils.sh"

# -----------------------------------------------------------------------------

main() {
  print_msg_info "Reset System Locking."

  execute "sudo rm /var/lib/apt/lists/lock &> /dev/null"        "Removing APT List Lock"
  execute "sudo rm /var/cache/apt/archives/lock &> /dev/null"   "Removing Cache APT Lock"
  execute "sudo rm /var/lib/dpkg/lock* &> /dev/null"            "Removing DPKG Lock File"
  execute "sudo dpkg --configure -a &> /dev/null"               "Reconfiguring Packages"
  break_line
}

main
