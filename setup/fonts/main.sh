#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" && . "./../utils.sh"

# ------------------------------------------------------------------------------

main () {

  print_msg_sub_info "Download VS Code fonts"
  download_fonts "kencrocken/FiraCodeiScript/blob/master/FiraCodeiScript-Bold.ttf"      "FiraCodeiScript-Bold.ttf"  "FiraCode iScript Bold"
  download_fonts "kencrocken/FiraCodeiScript/blob/master/FiraCodeiScript-Italic.ttf"    "FiraCodeiScript-Italic.ttf" "FiraCode iScript Italic"
  download_fonts "kencrocken/FiraCodeiScript/blob/master/FiraCodeiScript-Regular.ttf"   "FiraCodeiScript-Regular.ttf" "FiraCode iScript Regular"

  download_fonts "sainnhe/icursive-nerd-font/raw/master/Fira%20Code%20iCursive%20S12/Fira%20Code%20iCursive%20S12%20Bold.ttf"   "Fira\ Code\ iCursive\ S12\ Bold.ttf" "Fira Code iCursive S12 Bold"
  download_fonts "sainnhe/icursive-nerd-font/raw/master/Fira%20Code%20iCursive%20S12/Fira%20Code%20iCursive%20S12%20Italic.ttf"   "Fira\ Code\ iCursive\ S12\ Italic.ttf" "Fira Code iCursive S12 Italic"
  download_fonts "sainnhe/icursive-nerd-font/raw/master/Fira%20Code%20iCursive%20S12/Fira%20Code%20iCursive%20S12%20Regular.ttf"   "Fira\ Code\ iCursive\ S12\ Regular.ttf" "Fira Code iCursive S12 Regular"
  break_line

  # ------------------------------------------------------------------------------

  print_msg_sub_info "Download Gnome Terminal fonts"
  download_fonts "powerline/fonts/blob/master/UbuntuMono/Ubuntu%20Mono%20derivative%20Powerline.ttf" "Ubuntu\ Mono\ Derivative\ Powerline.ttf" "Ubuntu Mono Powerline"
  download_fonts "powerline/fonts/blob/master/UbuntuMono/Ubuntu%20Mono%20derivative%20Powerline%20Bold.ttf" "Ubuntu\ Mono\ Derivative\ Powerline\ Bold.ttf" "Ubuntu Mono Powerline Bold"
  download_fonts "powerline/fonts/blob/master/UbuntuMono/Ubuntu%20Mono%20derivative%20Powerline%20Bold%20Italic.ttf" "Ubuntu\ Mono\ Derivative\ Powerline\ Bold\ Italic.ttf" "Ubuntu Mono Powerline Bold Italic"
  download_fonts "powerline/fonts/blob/master/UbuntuMono/Ubuntu%20Mono%20derivative%20Powerline%20Italic.ttf" "Ubuntu\ Mono\ Derivative\ Powerline\ Italic.ttf" "Ubuntu Mono Powerline Italic"
  break_line

  # ------------------------------------------------------------------------------

  print_msg_sub_info "Download Editors fonts"
  download_fonts "tonsky/FiraCode/blob/master/distr/ttf/FiraCode-Bold.ttf"        "FiraCode-Bold.ttf" "FiraCode Bold"
  download_fonts "tonsky/FiraCode/blob/master/distr/ttf/FiraCode-Light.ttf"       "FiraCode-Light.ttf" "FiraCode Light"
  download_fonts "tonsky/FiraCode/blob/master/distr/ttf/FiraCode-Medium.ttf"      "FiraCode-Medium.ttf" "FiraCode Medium"
  download_fonts "tonsky/FiraCode/blob/master/distr/ttf/FiraCode-Regular.ttf"     "FiraCode-Regular.ttf" "FiraCode Regular"
  break_line

  # ------------------------------------------------------------------------------

  print_msg_sub_info "Download Others Terminals fonts"
  download_fonts "ryanoasis/nerd-fonts/releases/download/v2.0.0/Ubuntu.zip"       "Ubuntu.zip" "Ubuntu Nerd Fonts"
  download_fonts "ryanoasis/nerd-fonts/releases/download/v2.0.0/UbuntuMono.zip"   "UbuntuMono.zip" "Ubuntu Nerd Fonts Mono"
  break_line

  # ------------------------------------------------------------------------------

  print_msg_sub_info "Download Others fonts"
  download_fonts "microsoft/cascadia-code/releases/download/v1910.04/Cascadia.ttf" "Cascadia.ttf" "Cascadia Code"
  break_line

  # ------------------------------------------------------------------------------

  find ~/.fonts -name "*.zip" -exec unzip -o -q -d ~/.fonts {} \;
  find ~/.fonts -name "*.zip" -exec rm -rf {} \;
}

# ------------------------------------------------------------------------------

print_msg_info "Install Fonts"
main
