#!/usr/bin/env bash

###############################################################################
#      AUTHOR: @marcelohmdias
# DESCRIPTION:
#     VERSION: 1.0.0
# INSPIRED BY: https://github.com/goldsborough/progress
###############################################################################

###############################################################################
# INSTALLATION LIST
###############################################################################

#
FOLDERS=(
  .config/nvim
  .config/terminator
  .custom
  .fonts
  .psensor
  .tmux/plugins
)

#
FONTS=(
  # VS Code Forts
  kencrocken/FiraCodeiScript/blob/master/FiraCodeiScript-Bold.ttf
  kencrocken/FiraCodeiScript/blob/master/FiraCodeiScript-Italic.ttf
  kencrocken/FiraCodeiScript/blob/master/FiraCodeiScript-Regular.ttf
  # Gnome Terminal Fonts
  powerline/fonts/blob/master/UbuntuMono/Ubuntu%20Mono%20derivative%20Powerline%20Bold%20Italic.ttf
  powerline/fonts/blob/master/UbuntuMono/Ubuntu%20Mono%20derivative%20Powerline%20Bold.ttf
  powerline/fonts/blob/master/UbuntuMono/Ubuntu%20Mono%20derivative%20Powerline%20Italic.ttf
  powerline/fonts/blob/master/UbuntuMono/Ubuntu%20Mono%20derivative%20Powerline.ttf
  # Terminator Fonts
  ryanoasis/nerd-fonts/releases/download/v2.0.0/Ubuntu.zip
  ryanoasis/nerd-fonts/releases/download/v2.0.0/UbuntuMono.zip
  # Editor  Fonts
  tonsky/FiraCode/archive/master.zip
)

# List of PPAs to be added in the system
PPAS=(
  ppa:daniruiz/flat-remix
  ppa:dawidd0811/neofetch
  ppa:git-core/ppa
  ppa:noobslab/icons
  ppa:noobslab/themes
  ppa:papirus/papirus
  ppa:snwh/ppa
)

# Linux Update Commands
COMMANDS=(
  update
  upgrade
  autoclean
  autoremove
)

# Installation themes
THEMES=(
  arc-theme
  flat-remix
  numix-gtk-theme
  numix-icon-theme
  paper-icon-theme
  papirus-icon-theme
)

# Installation packages
PACKAGES=(
  curl
  git
  htop
  neofetch
  neovim
  psensor
  ruby
  ruby-dev
  ruby-colorize
  terminator
  tmux
  zsh
)

FOLDER_CLONE=(
  .oh-my-zsh/custom/plugins/zsh-256color
  .oh-my-zsh/custom/plugins/zsh-autosuggestions
  .oh-my-zsh/custom/plugins/zsh-completions
  .oh-my-zsh/custom/plugins/zsh-syntax-highlighting
  .oh-my-zsh/custom/themes/powerlevel9k
  .tmux/plugins/tpm
)

GIT_CLONE=(
  chrissicool/zsh-256color
  zsh-users/zsh-autosuggestions
  zsh-users/zsh-completions
  zsh-users/zsh-syntax-highlighting.git
  bhilburn/powerlevel9k.git
  tmux-plugins/tpm
)

###############################################################################
# BASIC FUNCTIONS
###############################################################################

# Keep all variables in the 'progress' namespace because
# this script is intended to be sourced (to avoid collisions with
# users' variables)

function ceiling_divide {
  ((result=($1 + ($2 - 1))/$2))
  echo $result
}

function string_of_length {
  # Space-separate a sequene of N numbers and
  # replace each number with the wanted character
  seq $1 | tr '\n' ' ' | perl -pe "s/[0-9]+ /$2/g"
}

function move_up {
  # The escape sequence \033[<number>A moves the cursor <number> lines up
  # The carriage return '\r' moves the cursor to the start of the line
  echo -en "\033[${1}A\r"
}

function move_down {
  # The escape sequence \033[<number>B moves the cursor <number> lines down
  # and the carriage return '\r' moves the cursor to the far left again (communism)
  echo -en "\033[${1}B\r"
}

function print_progress {
  if [ $1 -gt $2 ]; then
    return 1
  fi

  # The indicator (current_steps/total_steps) width is two times the total
  # number, since ultimately we'll want to print "(total/total)", plus 3 for
  # the parantheses and forward slash
  indicator_width=$(echo $2 | awk '{ print length($1) * 2 + 3}')

  # printf allows us to right justify the text according to the maximum width
  indicator=$(printf "%${indicator_width}s" "($1/$2)")
  indicator="\033[${progress_indicator_format}m${indicator}\033[0m"

  percent=$(echo "(100.0 * $1) / $2" | bc)
  percent="\033[${progress_percent_format}m[${percent}%]\033[0m"

  # PROGRESS in bold (usually displayed as bright formats)
  echo -en "\033[1mPROGRESS\033[0m: $indicator $3 $percent $4"
}

###############################################################################
# VARIABLES
###############################################################################

# These here can be configured externally
progress_number_of_steps=0
progress_width=25
progress_indicator_format=31
progress_percent_format=35

# The symbol for actual progress made
progress_symbol='\xE2\x96\xAC'
progress_symbol=$(echo -en "$progress_symbol")

# The escape code for the progresss format
progress_format=32

# The symbol for progress not yet made
progress_fill_symbol="$progress_symbol"
progress_fill_format=0

progress_divisor=0
progress_step_size=0
progress_unit=0
progress_fill_unit=0
progress_line=""

# How many steps we have made so far (out of $number_of_steps many)
# If the width is greater than the number of steps, we will have to
# advance the progress_index by more than 1 on each progress_step.
progress_step=0

# How many lines have been printed so far
progress_line_number=1
progress_max_lines=$(tput lines)
((progress_max_lines = progress_max_lines - 2))

###############################################################################
# PROGRESS FUNCTIONS
###############################################################################

function init_variables {
  # How many steps should equal an increment in one unit of progress
  # This value is important when the number of steps is greater than the width
  # because then it is not the case that one step = one extra bar of progress
  # but rather k steps will equal one bar of progress, with k > 1
  progress_divisor=$(ceiling_divide $progress_number_of_steps $progress_width)

  # The step size needs to be stored for the other extreme case, where the width
  # of the progress bar is greater (i.e. contains more units) than there are
  # steps. In that case, each step constitutes a greater number of units for the
  # progress bar.
  progress_step_size=$(ceiling_divide $progress_width $progress_number_of_steps)

  # One unit of progress (containing progress_step_size many characters)
  progress_unit=$(string_of_length $progress_step_size "$progress_symbol")

  # Throw in the escape codes. Note that the progress must be terminated with the
  # format escape of the filler, to restore its format after inserting the progress
  progress_unit=$(echo -en "\033[${progress_format}m$progress_unit\033[${progress_fill_format}m")

  # One unit of filler we replace with each unit of progress each time
  progress_fill_unit=$(string_of_length $progress_step_size "$progress_fill_symbol")

  # The actual progress bar
  progress_line=$(string_of_length $progress_width "$progress_fill_symbol")
  progress_line="\033[${progress_fill_format}m${progress_line}\033[0m"
}

function progress_step {

  # Don't overflow ...
  if [ -z $PROGRESS_STICKY ] && [ $progress_line_number -ge $progress_max_lines ]; then
    return 0
  elif [ $progress_step -gt $progress_number_of_steps ]; then
    return 0
  fi

  ((progress_step += 1))
  ((remainder=progress_step % progress_divisor))

  if [ $remainder -eq 0 ]; then
    # Replace one unit of the filler with one unit of progress
    progress_gsed_command="s/$progress_fill_unit/$progress_unit/"

    # If the fill symbol equals the progress symbol, we need to specify after
    # which match to start replacing, else we'll just match the first replacement
    # we made (since we'd be replacing e.g. xxxx with \033[31mx\033[0mxxx which
    # still contains x as the first text character, so next time we'd get
    # \033[31m\033[31mx\033[0m\033[0m instead of replacing the next fill character)
    if [ "$progress_fill_symbol" = "$progress_symbol" ]; then
        ((progress_index = progress_step / progress_divisor))
        progress_gsed_command="${progress_gsed_command}${progress_index}"
    fi
    progress_line="$(echo -e "$progress_line" | sed "$progress_gsed_command")"
  fi

  # We must always increment on the last step
  if [ $progress_step -eq $progress_number_of_steps ]; then
      ((progress_line_number += ${1:-1}))
  # Dont' increment when we've reached the end of the terminal
  elif [ $progress_line_number -lt $progress_max_lines ]; then
    # If nothing is passed, we increment by one (default), else if it is
    # -1, we do nothing (don't increment), else (if it's nonzero) we increment
    # by the given amount.
    if [ -z $1 ]; then
      ((progress_line_number += 1))
    elif [ $1 -ne -1 ]; then
      ((progress_line_number += $1))
    fi
  fi

  # Go back to the beginning of the line
  move_up $progress_line_number
  print_progress $progress_step $progress_number_of_steps "$progress_line" "$2"
  move_down $progress_line_number
}

# At the end, we fill up the progress bar. This is to account for when the step
# number and progress width are incompatible. This is the case when, for example,
# the width is greater than the number of steps and they are not divisible
function progress_end {
  if [ -z $PROGRESS_STICKY ] && [ $progress_line_number -ge $progress_max_lines ]; then
    return 0
  fi

  progress_line="$(echo -en "$progress_line" | perl -pe 's/$(echo $progress_fill_symbol)/'$progress_symbol'/g')"

  if [ $1 ]; then
    ((progress_line_number += $1))
  fi
  move_up $progress_line_number
  print_progress $progress_number_of_steps $progress_number_of_steps "$progress_line" "$2"
  move_down $progress_line_number
}

function progress_start {
  # Defines the new steps for the progress bar
  progress_step=0
  progress_number_of_steps=$1
  progress_width=$(($progress_number_of_steps * 2))

  init_variables

  print_progress $progress_step $progress_number_of_steps "$progress_line" "$2"
  echo ""
}

###############################################################################
# INSTALLATION FUNCTIONS
###############################################################################

function other_install {
  printf "\033c"

  echo "Installing NVM"
  wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash


  echo "Installing Oh My ZSH"
  sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -qO -)"


  echo "Installing Plug Vim"
  wget -qo- https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim ~/.config/nvim/autoload/plug.vim

  echo "Installing package Colorls"
  sudo gem install -q colorls
}

#
function git_clone_to_folders {
  local -n folders=$1
  local -n paths=$2

  printf "\033c"

  steps=$((${#folders[@]} * 2))
  progress_start "$steps" "Reading path list                                  "
  sleep 2

  for i in "${!folders[@]}"; do
    progress_step 0 "Preparing environment                                     "
    rm -rfd  ~/"${folders[$i]}" 2> /dev/null || echo > /dev/null
    sleep 2

    progress_step 0 "Cloning repository: ${paths[$i]}                         "
    git clone -q "https://github.com/${paths[$i]}" ~/"${folders[$i]}"
    sleep 2
  done

  progress_end 1 "Finishing execution                                          "
  sleep 2
}

#
function create_folders {
  local -n folders=$1

  printf "\033c"

  steps=$((${#folders[@]} + 2))
  progress_start "$steps" "Reading folder list                                 "
  sleep 2

  for folder in "${folders[@]}"; do

    progress_step 0 "Preparing environment                                     "
    rm -rfd ~/${folder} 2> /dev/null || echo > /dev/null
    sleep 2

    mkdir -p ~/${folder}
    progress_step 0 "Creating folder on path: ${folder}                        "
    sleep 2
  done

  progress_end 1 "Finishing execution                                          "
  sleep 2
}

#
function fonts_installer {
  local -n fonts=$1

  printf "\033c"

  steps=$((${#fonts[@]} + 2))

  progress_start "$steps" "Reading font list                                   "
  sleep 2

  for font in "${fonts[@]}"; do
    progress_step 0 "Download font                                             "
    wget -q "https://github.com/${font}" -P ~/.fonts
  done

  progress_step 0 "Unzipping files                                             "
  find ~/.fonts -name "*.zip" -exec unzip -q -d ~/.fonts  {} \;
  sleep 2

  progress_step 0 "Removing zip files                                          "
  find ~/.fonts -name "*.zip" -exec rm -rf	 {} \;
  sleep 2

  progress_end 1 "Finishing execution                                          "
  sleep 2
}

#
function run_commands {
  command="$1"
  action="$2"
  name="$3"
  local -n list=$4

  printf "\033c"

  steps=$((${#fonts[@]} + 2))
  progress_start "$steps" "Initializing execution                              "
  sleep 2

  for item in "${list[@]}"; do

    progress_step 0 "Preparing ${name}: ${item}"
    sleep 2

    progress_step 0 "${action} ${name}: ${item}                                "
    sudo $command $item
  done

  sleep 2
  progress_end 1 "Finishing execution                                          "
  sleep 2
}

###############################################################################
# INSTALLATION FUNCTIONS
###############################################################################

#
# create_folders FOLDERS

#
# fonts_installer FONTS

# #
# run_commands "add-apt-repository -y -n" "Adding" "PPA" PPAS

# #
# run_commands "apt-get -qq" "Executing" "command" COMMANDS

# #
# run_commands "apt-get install -qq" "Installing" "theme" THEMES

# #
# run_commands "apt-get install -qq" "Installing" "package" PACKAGES

#
git_clone_to_folders

#
# git_clone_to_folders FOLDER_CLONE GIT_CLONE



# sudo chsh -s /bin/zsh
