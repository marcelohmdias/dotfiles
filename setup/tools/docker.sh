#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" && . "./../utils.sh"

# -----------------------------------------------------------------------------

main() {
  local -a name= "disco" #"$(get_codiname)"
  local -r docker_url="https://download.docker.com/linux/ubuntu"
  local -r compose_version="1.24.1"
  local -r compose_url="https://github.com/docker/compose/releases/download/$compose_version/docker-compose-$(uname -s)-$(uname -m)"

  print_msg_sub_info "Docker"

  if cmd_exists "docker"; then
    print_msg_success "Docker Installed"
  else
    add_key "$docker_url/gpg"
    add_ppa_deb "[arch=amd64] $docker_url $name stable" "Add Docker PPA"
    break_line

    update_apt
    break_line

    install_package "docker-ce" "Docker Community"
    install_package "docker-ce-cli" "Docker Community CLI"
    install_package "containerd.io" "Containerd.io"

    execute "sudo curl -sL $compose_url -o /usr/local/bin/docker-compose" "Docker Compose"

    sudo chmod +x /usr/local/bin/docker-compose
  fi

}

# -----------------------------------------------------------------------------

main
break_line
