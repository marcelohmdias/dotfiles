#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" && . "./../utils.sh"

# -----------------------------------------------------------------------------

main() {
  print_msg_sub_info "Deb Packages"

  install_deb "DBeaver" "dbeaver" "https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb"

  install_deb "DockStation" "dockstation" "https://github.com/DockStation/dockstation/releases/download/v1.5.1/dockstation_1.5.1_amd64.deb"

  install_deb "Franz" "franz" "https://github.com/meetfranz/franz/releases/download/v5.2.0/franz_5.2.0_amd64.deb"

  install_deb "GitKraken" "gitkraken" "https://release.gitkraken.com/linux/gitkraken-amd64.deb"

  install_deb "Gnome AppFolders Manager" "gnome-appfolders-manager" "https://github.com/muflone/gnome-appfolders-manager/releases/download/0.3.1/gnome-appfolders-manager_0.3.1-1_all.deb"

  install_deb "Insync" "insync" "https://d2t3ff60b2tol4.cloudfront.net/builds/insync_1.5.7.37371-artful_amd64.deb"

  install_deb "Pencil" "pencil" "https://pencil.evolus.vn/dl/V3.0.4/Pencil_3.0.4_amd64.deb"

  install_deb "Stacer" "stacer" "https://github.com/oguzhaninan/Stacer/releases/download/v1.1.0/stacer_1.1.0_amd64.deb"

  install_deb "Steam" "steam" "https://steamcdn-a.akamaihd.net/client/installer/steam.deb"

  install_deb "Ukuu Kernel Update" "ukuu" "https://github.com/teejee2008/ukuu/releases/download/v18.9.1/ukuu-v18.9.1-amd64.deb"

  install_deb "Wps Office" "wps" "http://kdl.cc.ksosoft.com/wps-community/download/8722/wps-office_11.1.0.8722_amd64.deb"
}

# -----------------------------------------------------------------------------

main
break_line
