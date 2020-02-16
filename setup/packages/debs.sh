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

  install_deb "Graphql Playground" "graphql-playground" "https://github.com/prisma-labs/graphql-playground/releases/download/v1.8.10/graphql-playground-electron_1.8.10_amd64.deb"

  install_deb "Insync" "insync" "https://d2t3ff60b2tol4.cloudfront.net/builds/insync_3.0.29.40727-bionic_amd64.deb"

  install_deb "Stacer" "stacer" "https://github.com/oguzhaninan/Stacer/releases/download/v1.1.0/stacer_1.1.0_amd64.deb"

  install_deb "VS Code" "code" "https://go.microsoft.com/fwlink/?LinkID=760868"

  install_deb "Wps Office" "wps" "http://wdl1.pcfg.cache.wpscdn.com/wpsdl/wpsoffice/download/linux/9080/wps-office_11.1.0.9080.XA_amd64.deb"

  install_deb "Wps Translate" "WPS Translate" "https://doc-0o-7o-docs.googleusercontent.com/docs/securesc/6tioquud181vpmmpe4p7g356a4lbtot8/7bkr0bpd5pe6dbsmrlvk8ek1qre5gn2v/1581869700000/05233252432201595252/07199706726099415026/1uhxo3EsWjlBm02J0lDRvZH0Gy33a-a0J?e=download&authuser=0&nonce=e028liqcofdeq&user=07199706726099415026&hash=vm11c7qpu4mhstp0cfmrj53em4e2mq80"
}

# ------------------------------------------------------------------------------

main
break_line
