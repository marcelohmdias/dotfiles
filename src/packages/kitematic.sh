#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" && . "./../utils.sh"

# -----------------------------------------------------------------------------

main() {
  local -a version="0.17.8"
  local -a file="Kitematic-${version}-Ubuntu.zip"
  local -a debFile="Kitematic-${version}_amd64.deb"
  local -a url="https://github.com/docker/kitematic/releases/download/v${version}/${file}"

  local -a tmpFile="$HOME/Downloads"

  print_msg_sub_info "Kitematic"

  if ! cmd_exists "kitematic"; then
    execute "wget -qO $tmpFile/$file '$url'" "Download Kitematic"
    execute "unzip -q $tmpFile/$file -d $tmpFile" "Uzip File"
    execute "sudo dpkg -i $tmpFile/$debFile && sudo apt-get install -f &> /dev/null" "Install Kitematic"

    rm -f "$tmpFile/$file"
    rm -f "$tmpFile/$debFile"
  else
    print_msg_success "Kitematic Installed"
  fi
}

# -----------------------------------------------------------------------------

main
break_line
