#!/bin/bash

# ------------------------------------------------------------------------------
# |      AUTHOR: @marcelohmdias                                                |
# | DESCRIPTION: My dotfiles for Ubuntu PCs                                    |
# |     VERSION: v2.0.0                                                        |
# |     License: MIT                                                           |
# ------------------------------------------------------------------------------

declare -r GIT_USER="marcelohmdias"
declare -r REPOSITORY="$GIT_USER/dotfiles"
declare -r GITHUB_RAW="https://raw.githubusercontent.com"

# ------------------------------------------------------------------------------

declare -r GIT_ORIGIN="git@github.com:$REPOSITORY.git"
declare -r MY_DOTFILES="https://github.com/$REPOSITORY/tarball/master"
declare -r UTILS="$GITHUB_RAW/$REPOSITORY/master/setup/utils.sh"

# ------------------------------------------------------------------------------

declare DIRECTORY="$HOME/.custom"
declare SKIP_QUESTIONS=false

# ------------------------------------------------------------------------------
# |-------------------------- |  Helper Functions  | --------------------------|
# ------------------------------------------------------------------------------

term_clear() {
  clear; sleep 1
}

download() {

  local url="$1"
  local output="$2"

  wget -qO "$output" "$url" &>/dev/null

  return $?
}

download_utils() {

  local tmpFile=""

  tmpFile="$(mktemp /tmp/XXXXX)"

  download "$UTILS" "$tmpFile" &&
    . "$tmpFile" &&
    rm -rf "$tmpFile" &&
    return 0

  return 1
}

download_dotfiles() {

  local tmpFile=""

  print_msg_info "Download and extract archive"

  tmpFile="$(mktemp /tmp/XXXXX)"

  download "$MY_DOTFILES" "$tmpFile"
  print_result $? "Download archive" "true"
  break_line

  if ! $SKIP_QUESTIONS; then

    ask_for_confirmation "Do you want to store the dotfiles in '$DIRECTORY'?"

    if ! answer_is_yes; then
      DIRECTORY=""
      while [ -z "$DIRECTORY" ]; do
        ask "Please specify another location for the dotfiles (path): "
        DIRECTORY="$(get_answer)"
      done
    fi

    while [ -e "$DIRECTORY" ]; do
      ask_for_confirmation "'$DIRECTORY' already exists, do you want to overwrite it?"
      if answer_is_yes; then
        rm -rf "$DIRECTORY"
        break
      else
        DIRECTORY=""
        while [ -z "$DIRECTORY" ]; do
          ask "Please specify another location for the dotfiles (path): "
          DIRECTORY="$(get_answer)"
        done
      fi
    done

  else
    rm -rf "$DIRECTORY" &>/dev/null
  fi

  mkdir -p "$DIRECTORY"
  print_result $? "Create '$DIRECTORY'" "true"

  extract "$tmpFile" "$DIRECTORY"
  print_result $? "Extract archive" "true"

  rm -rf "$tmpFile"
  print_result $? "Remove archive"
  break_line

  cd "$DIRECTORY/setup" || return 1
}

extract() {

  local archive="$1"
  local output_dir="$2"

  if command -v "tar" &>/dev/null; then
    tar -zxf "$archive" --strip-components 1 -C "$output_dir"
    return $?
  fi

  return 1
}

# ------------------------------------------------------------------------------
# |-------------------------------- |  MAIN  | --------------------------------|
# ------------------------------------------------------------------------------

main() {

  cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1

  # Update system
  sudo apt-get update -y
  sudo apt-get upgrade -y
  term_clear

  # Install restricted packages
  sudo apt-get install -y ubuntu-restricted-extras
  term_clear

  # Removing unnecessary files
  sudo apt-get autoclean -y
  sudo apt-get autoremove -y
  term_clear

  # Download utility file
  if [ -f "utils.sh" ]; then
    . "./utils.sh" || exit 1
  else
    download_utils || exit 1
  fi

  sleep 1

  # Checking permission
  skip_questions "$@" && SKIP_QUESTIONS=true
  ask_for_sudo

  # Download all dotfile
  printf "%s" "${BASH_SOURCE[0]}" | grep "setup.sh" &>/dev/null || download_dotfiles

  sleep 1

  # Cleaning look files
  ./reset.sh

  # Running PPA Commands
  ./ppas/main.sh

  # Running directory creation command
  ./directories/main.sh

  # Running package download command
  ./packages/main.sh

  # Running tools download command
  ./tools/main.sh

  # Running font download command
  ./fonts/main.sh

  # Running command to set preferences
  ./preferences/main.sh

  # Finishing environment setup
  if ! $skipQuestions; then
    ./restart.sh
  fi
}

# ------------------------------------------------------------------------------

main "$@"
