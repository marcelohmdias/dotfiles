#!/bin/bash

# -----------------------------------------------------------------------------
# |      AUTHOR: @marcelohmdias                                               |
# | DESCRIPTION:                                                              |
# |     VERSION: v2.0.0                                                       |
# -----------------------------------------------------------------------------

declare -r USER="marcelohmdias"
declare -r REPOSITORY="$USER/dotfiles"

# -----------------------------------------------------------------------------

declare -r GIT_ORIGIN="git@github.com:$REPOSITORY.git"
declare -r MY_DOTFILES="https://github.com/$REPOSITORY/$USER/tarball/master"
declare -r UTILS="https://raw.githubusercontent.com/$REPOSITORY/master/src/utils.sh"

# -----------------------------------------------------------------------------

declare DIRECTORY="$HOME/.custom"
declare SKIP_QUESTIONS=false

# -----------------------------------------------------------------------------
# |------------------------- |  Helper Functions  | --------------------------|
# -----------------------------------------------------------------------------

download() {

  local url="$1"
  local output="$2"

  wget -qO "$output" "$url" &>/dev/null

  return $?

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

  cd "$DIRECTORY/src" || return 1

}

# -----------------------------------------------------------------------------
# |------------------------------- |  MAIN  | --------------------------------|
# -----------------------------------------------------------------------------

main() {

  cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1


  # -----------------------------------------------------------------------------

  if [ -f "utils.sh" ]; then
    . "./utils.sh" || exit 1
  else
    download_utils || exit 1
  fi

  # -----------------------------------------------------------------------------

  skip_questions "$@" && SKIP_QUESTIONS=true

  ask_for_sudo

  # -----------------------------------------------------------------------------

  printf "%s" "${BASH_SOURCE[0]}" | grep "setup.sh" &>/dev/null ||
    download_dotfiles

  # -----------------------------------------------------------------------------

  update_apt
  upgrade_apt
  autoclean_apt
  autoremove_apt

  # -----------------------------------------------------------------------------

  ./ppas/main.sh
  ./directories/main.sh
  ./fonts/main.sh
  ./packages/main.sh
  ./tools/main.sh

  # -----------------------------------------------------------------------------

}

main "$@"
