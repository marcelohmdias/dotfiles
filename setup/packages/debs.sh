#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" && . "./../utils.sh"

# ------------------------------------------------------------------------------

main() {
  print_msg_sub_info "Deb Packages"

  install_deb "DBeaver" "dbeaver" "https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb"

  install_deb "DockStation" "dockstation" "https://github.com/DockStation/dockstation/releases/download/v1.5.1/dockstation_1.5.1_amd64.deb"

  install_deb "Franz" "franz" "https://github.com/meetfranz/franz/releases/download/v5.4.0/franz_5.4.0_amd64.deb"

  install_deb "GitKraken" "gitkraken" "https://release.gitkraken.com/linux/gitkraken-amd64.deb"

  install_deb "Gnome AppFolders Manager" "gnome-appfolders-manager" "https://github.com/muflone/gnome-appfolders-manager/releases/download/0.3.1/gnome-appfolders-manager_0.3.1-1_all.deb"

  install_deb "Insync" "insync" "https://d2t3ff60b2tol4.cloudfront.net/builds/insync_3.0.23.40579-bionic_amd64.deb"

  install_deb "Stacer" "stacer" "https://github.com/oguzhaninan/Stacer/releases/download/v1.1.0/stacer_1.1.0_amd64.deb"

  install_deb "VS Code" "code" "https://go.microsoft.com/fwlink/?LinkID=760868"

  install_deb "Wps Office" "wps" "http://wdl1.pcfg.cache.wpscdn.com/wpsdl/wpsoffice/download/linux/8865/wps-office_11.1.0.8865_amd64.deb"

  # install_deb "Wps Fonts" "WPS Fonts" "http://kdl.cc.ksosoft.com/wps-community/download/fonts/wps-office-fonts_1.0_all.deb"
}

# ------------------------------------------------------------------------------

main
break_line
