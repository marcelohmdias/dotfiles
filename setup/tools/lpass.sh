#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" && . "./../utils.sh"

# -----------------------------------------------------------------------------

main() {

  local -a version="1.3.3"
  local -a file="lastpass-cli-${version}.tar.gz"
  local -a url="https://github.com/lastpass/lastpass-cli/releases/download/v${version}/$file"

  local -a tmpFile="$HOME/Downloads"

  print_msg_sub_info "LastPass CLI"

  if cmd_exists "lpass"; then
    print_msg_success "LastPass CLI Installed"
  else
    execute "wget -qO $tmpFile/$file '$url'" "Download LastPass CLI"

    mkdir "$tmpFile/lastpass" &> /dev/null

    execute "tar -zxf $tmpFile/$file --strip-components 1 -C $tmpFile/lastpass" "Uzip File"

    execute "sudo make -C $tmpFile/lastpass && sudo make -C $tmpFile/lastpass install &> /dev/null" "Install LastPass CLI"

    sudo rm -rf "$tmpFile/lastpass" &> /dev/null
    sudo rm -rf "$tmpFile/$file" &> /dev/null
  fi
}

# -----------------------------------------------------------------------------

main
break_line
