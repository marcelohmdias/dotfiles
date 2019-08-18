#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" && . "./../utils.sh"

# -----------------------------------------------------------------------------

declare -a VSC_FONTS=(
  "kencrocken/FiraCodeiScript/blob/master/FiraCodeiScript-Bold.ttf"
  "kencrocken/FiraCodeiScript/blob/master/FiraCodeiScript-Italic.ttf"
  "kencrocken/FiraCodeiScript/blob/master/FiraCodeiScript-Regular.ttf"
)

declare -a VSC_FONT_NAMES=(
  "FiraCode iScript Bold"
  "FiraCode iScript Italic"
  "FiraCode iScript Regular"
)

# -----------------------------------------------------------------------------

declare -a FONTS=(
  # VS Code Forts
  "kencrocken/FiraCodeiScript/blob/master/FiraCodeiScript-Bold.ttf"
  "kencrocken/FiraCodeiScript/blob/master/FiraCodeiScript-Italic.ttf"
  "kencrocken/FiraCodeiScript/blob/master/FiraCodeiScript-Regular.ttf"
  # Gnome Terminal Fonts
  "powerline/fonts/blob/master/UbuntuMono/Ubuntu%20Mono%20derivative%20Powerline.ttf"
  "powerline/fonts/blob/master/UbuntuMono/Ubuntu%20Mono%20derivative%20Powerline%20Bold.ttf"
  "powerline/fonts/blob/master/UbuntuMono/Ubuntu%20Mono%20derivative%20Powerline%20Bold%20Italic.ttf"
  "powerline/fonts/blob/master/UbuntuMono/Ubuntu%20Mono%20derivative%20Powerline%20Italic.ttf"
  # Editor Fonts
  "tonsky/FiraCode/blob/master/distr/ttf/FiraCode-Bold.ttf"
  "tonsky/FiraCode/blob/master/distr/ttf/FiraCode-Light.ttf"
  "tonsky/FiraCode/blob/master/distr/ttf/FiraCode-Medium.ttf"
  "tonsky/FiraCode/blob/master/distr/ttf/FiraCode-Regular.ttf"
  # Terminator Fonts
  "ryanoasis/nerd-fonts/releases/download/v2.0.0/Ubuntu.zip"
  "ryanoasis/nerd-fonts/releases/download/v2.0.0/UbuntuMono.zip"
)

declare -a NAMES_FONTS=(
  # FiraCode iScript
  "FiraCode iScript Bold"
  "FiraCode iScript Italic"
  "FiraCode iScript Regular"
  # Ubuntu Mono Powerline
  "Ubuntu Mono Powerline"
  "Ubuntu Mono Powerline Bold"
  "Ubuntu Mono Powerline Bold Italic"
  "Ubuntu Mono Powerline Italic"
  # FiraCode
  "FiraCode Bold"
  "FiraCode Light"
  "FiraCode Medium"
  "FiraCode Regular"
  # Ubuntu Nerd Fonts
  "Ubuntu Nerd Fonts"
  "Ubuntu Nerd Fonts Mono"
)

# -----------------------------------------------------------------------------

declare -a FONTS=(
  # VS Code Forts
  "kencrocken/FiraCodeiScript/blob/master/FiraCodeiScript-Bold.ttf"
  "kencrocken/FiraCodeiScript/blob/master/FiraCodeiScript-Italic.ttf"
  "kencrocken/FiraCodeiScript/blob/master/FiraCodeiScript-Regular.ttf"
  # Gnome Terminal Fonts
  "powerline/fonts/blob/master/UbuntuMono/Ubuntu%20Mono%20derivative%20Powerline.ttf"
  "powerline/fonts/blob/master/UbuntuMono/Ubuntu%20Mono%20derivative%20Powerline%20Bold.ttf"
  "powerline/fonts/blob/master/UbuntuMono/Ubuntu%20Mono%20derivative%20Powerline%20Bold%20Italic.ttf"
  "powerline/fonts/blob/master/UbuntuMono/Ubuntu%20Mono%20derivative%20Powerline%20Italic.ttf"
  # Editor Fonts
  "tonsky/FiraCode/blob/master/distr/ttf/FiraCode-Bold.ttf"
  "tonsky/FiraCode/blob/master/distr/ttf/FiraCode-Light.ttf"
  "tonsky/FiraCode/blob/master/distr/ttf/FiraCode-Medium.ttf"
  "tonsky/FiraCode/blob/master/distr/ttf/FiraCode-Regular.ttf"
  # Terminator Fonts
  "ryanoasis/nerd-fonts/releases/download/v2.0.0/Ubuntu.zip"
  "ryanoasis/nerd-fonts/releases/download/v2.0.0/UbuntuMono.zip"
)

declare -a NAMES_FONTS=(
  # FiraCode iScript
  "FiraCode iScript Bold"
  "FiraCode iScript Italic"
  "FiraCode iScript Regular"
  # Ubuntu Mono Powerline
  "Ubuntu Mono Powerline"
  "Ubuntu Mono Powerline Bold"
  "Ubuntu Mono Powerline Bold Italic"
  "Ubuntu Mono Powerline Italic"
  # FiraCode
  "FiraCode Bold"
  "FiraCode Light"
  "FiraCode Medium"
  "FiraCode Regular"
  # Ubuntu Nerd Fonts
  "Ubuntu Nerd Fonts"
  "Ubuntu Nerd Fonts Mono"
)

# -----------------------------------------------------------------------------

declare -a FONTS=(
  # VS Code Forts
  "kencrocken/FiraCodeiScript/blob/master/FiraCodeiScript-Bold.ttf"
  "kencrocken/FiraCodeiScript/blob/master/FiraCodeiScript-Italic.ttf"
  "kencrocken/FiraCodeiScript/blob/master/FiraCodeiScript-Regular.ttf"
  # Gnome Terminal Fonts
  "powerline/fonts/blob/master/UbuntuMono/Ubuntu%20Mono%20derivative%20Powerline.ttf"
  "powerline/fonts/blob/master/UbuntuMono/Ubuntu%20Mono%20derivative%20Powerline%20Bold.ttf"
  "powerline/fonts/blob/master/UbuntuMono/Ubuntu%20Mono%20derivative%20Powerline%20Bold%20Italic.ttf"
  "powerline/fonts/blob/master/UbuntuMono/Ubuntu%20Mono%20derivative%20Powerline%20Italic.ttf"
  # Editor Fonts
  "tonsky/FiraCode/blob/master/distr/ttf/FiraCode-Bold.ttf"
  "tonsky/FiraCode/blob/master/distr/ttf/FiraCode-Light.ttf"
  "tonsky/FiraCode/blob/master/distr/ttf/FiraCode-Medium.ttf"
  "tonsky/FiraCode/blob/master/distr/ttf/FiraCode-Regular.ttf"
  # Terminator Fonts
  "ryanoasis/nerd-fonts/releases/download/v2.0.0/Ubuntu.zip"
  "ryanoasis/nerd-fonts/releases/download/v2.0.0/UbuntuMono.zip"
)

declare -a NAMES_FONTS=(
  # FiraCode iScript
  "FiraCode iScript Bold"
  "FiraCode iScript Italic"
  "FiraCode iScript Regular"
  # Ubuntu Mono Powerline
  "Ubuntu Mono Powerline"
  "Ubuntu Mono Powerline Bold"
  "Ubuntu Mono Powerline Bold Italic"
  "Ubuntu Mono Powerline Italic"
  # FiraCode
  "FiraCode Bold"
  "FiraCode Light"
  "FiraCode Medium"
  "FiraCode Regular"
  # Ubuntu Nerd Fonts
  "Ubuntu Nerd Fonts"
  "Ubuntu Nerd Fonts Mono"
)

# -----------------------------------------------------------------------------

get_fonts() {

  local -n fonts=$1
  local -n names=$2

  for i in "${!fonts[@]}"; do
    download_fonts "${fonts[$i]}" "${names[$i]}"
  done

  find ~/.fonts -name "*.zip" -exec unzip -q -d ~/.fonts {} \;

  find ~/.fonts -name "*.zip" -exec rm -rf {} \;

}

# -----------------------------------------------------------------------------

print_msg_info "Download system fonts."
get_fonts FONTS NAMES_FONTS

# -----------------------------------------------------------------------------

print_msg_sub_info "Apps"
add_ppas PPAS_APPS NAMES_APP
break_line
