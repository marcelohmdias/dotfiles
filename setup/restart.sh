#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" && . "./utils.sh"

# -----------------------------------------------------------------------------

main() {
  print_msg_info "Restart System."

  ask_for_confirmation "Do you want to restart?"
  break_line

  if answer_is_yes; then
    sudo shutdown -r now &> /dev/null
  fi
}

main
