#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" && . "./../utils.sh"

# -----------------------------------------------------------------------------

main() {
  print_msg_sub_info "System Settings for Ubuntu"

  install_package "apt-transport-https" "Plugin for apt"
  install_package "build-essential" "Essential packages for building"

  install_package \
    "language-pack-gnome-pt language-pack-pt-base" \
    "PT-BR translation packages"

  install_package "ubuntu-restricted-extras" "Extra Libraries for Ubuntu"

  install_package "gnome-shell-extensions" "Gnome Shell Extensions Plugin"

  install_package "bash-completion" "Bash Completion" "--no-install-recommends"

  install_package "cmake" "CMake" "--no-install-recommends"

  install_package "libcurl4" "Lib cURL" "--no-install-recommends"

  install_package "libcurl4-openssl-dev" "Lib cURL Open SSL DEV" "--no-install-recommends"

  install_package "libssl-dev" "Lib SSL DEV" "--no-install-recommends"

  install_package "libxml2" "Lib XML" "--no-install-recommends"

  install_package "libxml2-dev" "Lib XML DEV" "--no-install-recommends"

  install_package "libssl1.1" "Lib SSL 1.1" "--no-install-recommends"

  install_package "pkg-config" "Pkg Config" "--no-install-recommends"

  install_package "ca-certificates" "CA Certificates" "--no-install-recommends"

  install_package "xclip" "XClip" "--no-install-recommends"

  break_line
}

# -----------------------------------------------------------------------------

main
