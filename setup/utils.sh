#!/bin/bash

# ------------------------------------------------------------------------------
# |------------------------------ |  Variables  | -----------------------------|
# ------------------------------------------------------------------------------

declare -r BLACK=235
declare -r RED=196
declare -r GREEN=34
declare -r YELLOW=221
declare -r BLUE=33
declare -r PURPLE=135
declare -r MAGENTA=201
declare -r WHITE=255

# ------------------------------------------------------------------------------
# |-------------------------- |  Ask and Question  | --------------------------|
# ------------------------------------------------------------------------------

answer_is_yes() {
  [[ "$REPLY" =~ ^[Yy]$ ]] && return 0 || return 1
}

ask() {
  print_msg_question "$1"
  read -r
}

ask_for_confirmation() {
  print_msg_question "$1 (y/n) "
  read -r -n 1
  break_line
}

ask_for_sudo() {
  sudo -v &>/dev/null

  while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
  done &>/dev/null &
}

get_answer() {
  printf "%s" "$REPLY"
}

skip_questions() {
  while :; do
    case $1 in
    -y | --yes) return 0 ;;
    *) break ;;
    esac
    shift 1
  done

  return 1
}

# ------------------------------------------------------------------------------
# |--------------------------- |  Commands Utils  | ---------------------------|
# ------------------------------------------------------------------------------

cmd_exists() {
  command -v "$1" &>/dev/null
}

download_fonts() {
  local url="https://github.com/$1"

  execute "wget -q $url -O $HOME/.fonts/$2" "$3"
}

execute() {
  local -r CMDS="$1"
  local -r MSG="${2:-$1}"
  local -r TMP_FILE="$(mktemp /tmp/XXXXX)"

  local exitCode=0
  local cmdsPID=""

  # If the current process is ended,
  # also end all its subprocesses.

  set_trap "EXIT" "kill_all_subprocesses"

  # Execute commands in background

  eval "$CMDS" \
    &>/dev/null \
    2>"$TMP_FILE" &

  cmdsPID=$!

  # Show a spinner if the commands
  # require more time to complete.

  show_spinner "$cmdsPID" "$CMDS" "$MSG"

  # Wait for the commands to no longer be executing
  # in the background, and then get their exit code.

  wait "$cmdsPID" &>/dev/null
  exitCode=$?

  # Print output based on what happened.

  print_result $exitCode "$MSG"

  if [ $exitCode -ne 0 ]; then
    print_error_stream <"$TMP_FILE"
  fi

  rm -rf "$TMP_FILE"

  return $exitCode
}

get_codiname() {
  cat /etc/lsb-release |
    grep DISTRIB_CODENAME= |
    tr "DISTRIB_CODENAME=" " " |
    xargs
}

get_release() {
  cat /etc/lsb-release |
    grep DISTRIB_RELEASE= |
    tr "DISTRIB_RELEASE=" " " |
    xargs
}

kill_all_subprocesses() {
  local i=""

  for i in $(jobs -p); do
    kill "$i"
    wait "$i" &>/dev/null
  done
}

set_trap() {
  trap -p "$1" | grep "$2" &>/dev/null || trap "$2" "$1"
}

# ------------------------------------------------------------------------------
# |--------------------------- |  Print Messages  | ---------------------------|
# ------------------------------------------------------------------------------

print_error_stream() {
  while read -r line; do
    print_msg_error "↳ ERROR: $line"
  done
}

print_in_color() {
  printf "%b" "$(tput setaf "$2" 2>/dev/null)" "$1" "$(tput sgr0 2>/dev/null)"
}

print_in_black() {
  print_in_color "$1" "$BLACK"
}

print_in_blue() {
  print_in_color "$1" "$BLUE"
}

print_in_green() {
  print_in_color "$1" "$GREEN"
}

print_in_magenta() {
  print_in_color "$1" "$MAGENTA"
}

print_in_purple() {
  print_in_color "$1" "$PURPLE"
}

print_in_red() {
  print_in_color "$1" "$RED"
}

print_in_white() {
  print_in_color "$1" "$WHITE"
}

print_in_yellow() {
  print_in_color "$1" "$YELLOW"
}

print_msg_error() {
  print_in_red "    [✘] $1 $2\n"
}

print_msg_info() {
  print_in_blue "\n •➤ $1\n\n"
}

print_msg_question() {
  print_in_white "    [?] $1"
}

print_msg_sub_info() {
  print_in_purple "    • $1\n"
}

print_msg_success() {
  print_in_green "    [✔] $1\n"
}

print_msg_warning() {
  print_in_yellow "    [ǃ] $1\n"
}

print_result() {
  if [ "$1" -eq 0 ]; then
    print_msg_success "$2"
  else
    print_msg_error "$2"
  fi

  return "$1"
}

# ------------------------------------------------------------------------------
# |--------------------------- |  System Commands  | --------------------------|
# ------------------------------------------------------------------------------

add_key() {
  local -r url="$1"
  local -r args="$2"
  execute "wget -qO - $url | sudo apt-key $args add -" "Add Key"
}

add_ppa() {
  execute "sudo add-apt-repository -y -n ppa:$1" "$2"
}

add_ppa_deb() {
  execute "sudo add-apt-repository -y -n 'deb $1'" "$2"
}

autoclean_apt() {
  execute "sudo apt-get autoclean -qqy" "APT Autoclean"
}

autoremove_apt() {
  execute "sudo apt-get autoremove -qqy" "APT Autoremove"
}

install_code_ext() {
  local -r extensions="$1"
  local -r ext="$2"
  local -r name="$3"

  if [ "$(echo "$extensions" | grep -c "$ext")" -eq 1 ]; then
    print_msg_success "Extension $name installed"
  else
    execute "code --install-extension $ext" "Install extension $name"
  fi
}

install_deb() {
  local -r name="$1"
  local -r package="$2"
  local -r url="$3"

  tmpFile="$(mktemp /tmp/XXXXX)"

  if ! cmd_exists "$package"; then
    execute "wget -qO $tmpFile '$url'" "Download $name"
    execute "sudo dpkg --force-all -i $tmpFile &> /dev/null && sudo apt-get install -f -y &> /dev/null" "Install $name"
    rm -f "$tmpFile"
  else
    print_msg_success "$name Instaled"
  fi
}

install_package() {
  local -r package="$1"
  local -r name="$2"
  local -r args="$3"

  if ! package_is_installed "$package"; then
    execute "sudo apt-get install -qqy $args $package" "Install $name"
  else
    print_msg_success "$name Instaled"
  fi
}

install_snap() {
  local -r package="$1"
  local -r name="$2"
  local -r args="$3"

  if ! package_is_installed "$package"; then
    execute "sudo snap install $package $args &> /dev/null" "Install $name"
  else
    print_msg_success "$name Installed"
  fi
}

mkd() {
  if [ -n "$1" ]; then
    if [ -e "$1" ]; then
      if [ ! -d "$1" ]; then
        print_msg_error "$1 - a file with the same name already exists!"
      else
        print_msg_success "$1"
      fi
    else
      execute "mkdir -p $1" "$1"
    fi
  fi
}

package_is_installed() {
  dpkg -s "$1" &>/dev/null
}

update_apt() {
  execute "sudo apt-get update -qqy" "APT Update"
}

upgrade_apt() {
  execute "sudo apt-get upgrade -qqy" "APT Upgrade"
}

# ------------------------------------------------------------------------------
# |------------------------------ |  Terminal  | ------------------------------|
# ------------------------------------------------------------------------------

break_line() {
  printf "\n"
}

show_spinner() {

  local -r FRAMES="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"

  # shellcheck disable=SC2034
  local -r NUMBER_OR_FRAMES=${#FRAMES}

  local -r CMDS="$2"
  local -r MSG="$3"
  local -r PID="$1"

  local i=0
  local frameText=""

  printf "\n\n\n"
  tput cuu 3

  tput sc

  # Display spinner while the commands are being executed.

  while kill -0 "$PID" &>/dev/null; do

    frameText="    [${FRAMES:i++%NUMBER_OR_FRAMES:1}] $MSG"

    printf "%s\n" "$frameText"
    sleep 0.075

    tput rc

  done

}
