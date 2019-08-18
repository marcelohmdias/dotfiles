#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" && . "./../utils.sh"

# -----------------------------------------------------------------------------

main() {
  print_msg_sub_info "Snap Packages"

  install_snap "postman"              "Postman"
  install_snap "slack"                "Slack"
  install_snap "spotify"              "Spotify"
  install_snap "telegram-desktop"     "Telegram"
  install_snap "zenkit"               "Zenkit"

  break_line
}

# -----------------------------------------------------------------------------

main
