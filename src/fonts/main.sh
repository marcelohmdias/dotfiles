#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" && . "./../utils.sh"

# -----------------------------------------------------------------------------

main () {

  print_msg_sub_info "Download VS Code fonts"
  download_fonts "kencrocken/FiraCodeiScript/blob/master/FiraCodeiScript-Bold.ttf" "FiraCode iScript Bold"
  download_fonts "kencrocken/FiraCodeiScript/blob/master/FiraCodeiScript-Italic.ttf" "FiraCode iScript Italic"
  download_fonts "kencrocken/FiraCodeiScript/blob/master/FiraCodeiScript-Regular.ttf" "FiraCode iScript Regular"
  break_line

  # -----------------------------------------------------------------------------

  print_msg_sub_info "Download Gnome Terminal fonts"
  download_fonts "powerline/fonts/blob/master/UbuntuMono/Ubuntu%20Mono%20derivative%20Powerline.ttf" "Ubuntu Mono Powerline"
  download_fonts "powerline/fonts/blob/master/UbuntuMono/Ubuntu%20Mono%20derivative%20Powerline%20Bold.ttf" "Ubuntu Mono Powerline Bold"
  download_fonts "powerline/fonts/blob/master/UbuntuMono/Ubuntu%20Mono%20derivative%20Powerline%20Bold%20Italic.ttf" "Ubuntu Mono Powerline Bold Italic"
  download_fonts "powerline/fonts/blob/master/UbuntuMono/Ubuntu%20Mono%20derivative%20Powerline%20Italic.ttf" "Ubuntu Mono Powerline Italic"
  break_line

  # -----------------------------------------------------------------------------

  print_msg_sub_info "Download Editors fonts"
  download_fonts "tonsky/FiraCode/blob/master/distr/ttf/FiraCode-Bold.ttf" "FiraCode Bold"
  download_fonts "tonsky/FiraCode/blob/master/distr/ttf/FiraCode-Light.ttf" "FiraCode Light"
  download_fonts "tonsky/FiraCode/blob/master/distr/ttf/FiraCode-Medium.ttf" "FiraCode Medium"
  download_fonts "tonsky/FiraCode/blob/master/distr/ttf/FiraCode-Regular.ttf" "FiraCode Regular"
  break_line

  # -----------------------------------------------------------------------------

  print_msg_sub_info "Download Others Terminals fonts"
  download_fonts "ryanoasis/nerd-fonts/releases/download/v2.0.0/Ubuntu.zip" "Ubuntu Nerd Fonts"
  download_fonts "ryanoasis/nerd-fonts/releases/download/v2.0.0/UbuntuMono.zip" "Ubuntu Nerd Fonts Mono"
  break_line

  # -----------------------------------------------------------------------------

  find ~/.fonts -name "*.zip" -exec unzip -q -d ~/.fonts {} \;
  find ~/.fonts -name "*.zip" -exec rm -rf {} \;
}

# -----------------------------------------------------------------------------

print_msg_info "Install Fonts"
main
