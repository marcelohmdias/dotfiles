#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" && . "./../utils.sh"

# ------------------------------------------------------------------------------

create_firefox_icon() {
  sudo touch /usr/share/applications/firefox-developer.desktop \
    && printf '%s\n' \
    "[Desktop Entry]" \
    "Name=Firefox Developer" \
    "GenericName=Firefox Developer Edition" \
    "Exec=/usr/local/bin/firefox" \
    "Terminal=false" \
    "Icon=firefox-developer-edition" \
    "Type=Application" \
    "Categories=Application;Network;X-Developer;" \
    "Comment=Firefox Developer Edition Web Browser" \
    | sudo tee /usr/share/applications/firefox-developer.desktop &> /dev/null
}

install_brave() {
  local -a name="$(get_codiname)"

  if package_is_installed "brave-browser"; then
    print_msg_success "Breave Installed"
  else
    add_key "https://brave-browser-apt-release.s3.brave.com/brave-core.asc" "--keyring /etc/apt/trusted.gpg.d/brave-browser-release.gpg"

    source /etc/os-release

    echo "deb [arch=amd64] https://brave-browser-apt-release.s3.brave.com/ $name main" | \
    sudo tee /etc/apt/sources.list.d/brave-browser-release-${name}.list &> /dev/null

    update_apt

    install_package "brave-browser" "Brave"
  fi
}

install_firefox() {
  if package_is_installed "firefox"; then
    execute "sudo apt-get remove --purge -qqy firefox" "Remove Firefox"
  fi

  version="71.0b2"
  tmpFile="$(mktemp /tmp/XXXXX)"
  firefox="https://download-installer.cdn.mozilla.net/pub/devedition/releases/$version/linux-x86_64/pt-BR/firefox-$version.tar.bz2"

  if [ ! -f "/opt/firefox/firefox" ]; then
    execute "wget -P $tmpFile $firefox" "Download Firefox Developer Edition"
    execute "sudo tar -xvf $tmpFile/firefox-*.tar.bz2 -C $tmpFile" "Unzip package"
    execute "sudo mv $tmpFile/firefox /opt" "Move files"
  fi

  if [ ! -f "/usr/local/bin/firefox" ]; then
    sudo ln -s /opt/firefox/firefox /usr/local/bin/firefox
  fi

  if [ ! -f "/usr/share/applications/firefox-developer.desktop" ]; then
    create_firefox_icon
    sudo chmod +x /usr/share/applications/firefox-developer.desktop
  fi

  print_msg_success "Firefox Developer Edition Installed"
}

install_google() {
  if package_is_installed "google-chrome" || package_is_installed "google-chrome-stable"; then
    print_msg_success "Google Chrome Installed"
  else
    install_deb "Google Chrome" "google-chrome-stable" "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
  fi

  install_package "chrome-gnome-shell" "Gnome Shell for Chrome plugin"
}

# ------------------------------------------------------------------------------

main() {
  print_msg_sub_info "Browsers"

  install_brave
  install_firefox
  install_google
}

# ------------------------------------------------------------------------------

main
break_line
