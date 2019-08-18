#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" && . "./../utils.sh"

# -----------------------------------------------------------------------------

main() {
  local -a url="https://packages.microsoft.com/keys/microsoft.asc"
  local -a repository="https://packages.microsoft.com/repos/vscode"
  local -a file="/etc/apt/sources.list.d/vscode.list"

  print_msg_sub_info "VS Code"

  if cmd_exists "code"; then
    print_msg_success "VS Code Installed"
  else
    execute "wget -qO - $url | gpg --dearmor > microsoft.gpg" "Add Key"

    execute "sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/ &> /dev/null" "Install Key"

    sudo sh -c 'echo "deb [arch=amd64] $repository stable main" > $file' &> /dev/null

    update_apt

    install_package "code" "VS Code"

    sleep 0.5

  fi

  list="$(code --list-extensions)"

  break_line
  print_msg_sub_info "VS Code Extension"

  code_install_ext "$list" "kaicataldo.alpenglow-monokai"                   "Alpenglow Monokai"
  code_install_ext "$list" "apollographql.vscode-apollo"                    "Apollo GraphQL"
  code_install_ext "$list" "ms-vscode.atom-keybindings"                     "Atom Keymap"
  code_install_ext "$list" "formulahendry.auto-close-tag"                   "Auto Close Tag"
  code_install_ext "$list" "formulahendry.auto-rename-tag"                  "Auto Rename Tag"
  code_install_ext "$list" "HookyQR.beautify"                               "Beautify"
  code_install_ext "$list" "alefragnani.Bookmarks"                          "Bookmarks"
  code_install_ext "$list" "wmaurer.change-case"                            "Change-case"
  code_install_ext "$list" "softwaredotcom.swdc-vscode"                     "Code Time"
  code_install_ext "$list" "kisstkondoros.vscode-codemetrics"               "CodeMetrics"
  code_install_ext "$list" "anseki.vscode-color"                            "Color Picker"
  code_install_ext "$list" "kamikillerto.vscode-colorize"                   "Colorize"
  code_install_ext "$list" "ExodiusStudios.comment-anchors"                 "Comment Anchors"
  code_install_ext "$list" "pranaygp.vscode-css-peek"                       "CSS Peek"
  code_install_ext "$list" "Dart-Code.dart-code"                            "Dart"
  code_install_ext "$list" "msjsdiag.debugger-for-chrome"                   "Debugger for Chrome"
  code_install_ext "$list" "ms-azuretools.vscode-docker"                    "Docker"
  code_install_ext "$list" "joelday.docthis"                                "Document This"
  code_install_ext "$list" "mikestead.dotenv"                               "DotENV"
  code_install_ext "$list" "EditorConfig.EditorConfig"                      "EditorConfig"
  code_install_ext "$list" "mjmcloug.vscode-elixir"                         "Elixir"
  code_install_ext "$list" "dbaeumer.vscode-eslint"                         "Eslint"
  code_install_ext "$list" "file-icons.file-icons"                          "File-icons"
  code_install_ext "$list" "abierbaum.vscode-file-peek"                     "File Peek"
  code_install_ext "$list" "mkxml.vscode-filesize"                          "Filesize"
  code_install_ext "$list" "Dart-Code.flutter"                              "Flutter"
  code_install_ext "$list" "tombonnike.vscode-status-bar-format-toggle"     "Formatting Toggle"
  code_install_ext "$list" "donjayamanne.githistory"                        "Git History"
  code_install_ext "$list" "lamartire.git-indicators"                       "Git Indicators"
  code_install_ext "$list" "codezombiech.gitignore"                         "Gitignore"
  code_install_ext "$list" "eamodio.gitlens"                                "GitLens"
  code_install_ext "$list" "ms-vscode.Go"                                   "Go"
  code_install_ext "$list" "kumar-harsh.graphql-for-vscode"                 "GraphQL"
  code_install_ext "$list" "vincaslt.highlight-matching-tag"                "Highlight Matching Tag"
  code_install_ext "$list" "kisstkondoros.vscode-gutter-preview"            "Image preview"
  code_install_ext "$list" "wix.vscode-import-cost"                         "Import Cost"
  code_install_ext "$list" "Zignd.html-css-class-completion"                "IntelliSense for CSS class names in HTML"
  code_install_ext "$list" "Orta.vscode-jest"                               "Jest"
  code_install_ext "$list" "MS-vsliveshare.vsliveshare"                     "Live Share"
  code_install_ext "$list" "yzhang.markdown-all-in-one"                     "Markdown All in One"
  code_install_ext "$list" "eg2.vscode-npm-script"                          "NPM"
  code_install_ext "$list" "karanba.npm-helper"                             "NPM Helper"
  code_install_ext "$list" "christian-kohler.npm-intellisense"              "NPM Intellisense"
  code_install_ext "$list" "IBM.output-colorizer"                           "Output Colorizer"
  code_install_ext "$list" "ryu1kn.partial-diff"                            "Partial Diff"
  code_install_ext "$list" "christian-kohler.path-intellisense"             "Path Intellisense"
  code_install_ext "$list" "johnpapa.vscode-peacock"                        "Peacock"
  code_install_ext "$list" "pnp.polacode"                                   "Polacode"
  code_install_ext "$list" "MS-CEINTL.vscode-language-pack-pt-BR"           "Portuguese (Brazil) Language Pack"
  code_install_ext "$list" "esbenp.prettier-vscode"                         "Prettier - Code formatter"
  code_install_ext "$list" "mohsen1.prettify-json"                          "Prettify JSON"
  code_install_ext "$list" "alefragnani.project-manager"                    "Project Manager"
  code_install_ext "$list" "ms-python.python"                               "Python"
  code_install_ext "$list" "chrmarti.regex"                                 "Regex Previewer"
  code_install_ext "$list" "le0zh.vscode-regexp-preivew"                    "Regex Previewer and Editor"
  code_install_ext "$list" "jakob101.RelativePath"                          "Relative Path"
  code_install_ext "$list" "ms-vscode-remote.remote-containers"             "Remote - Containers"
  code_install_ext "$list" "ms-vscode-remote.remote-ssh"                    "Remote - SSH"
  code_install_ext "$list" "Syler.sass-indented"                            "Sass"
  code_install_ext "$list" "Shan.code-settings-sync"                        "Settings Sync"
  code_install_ext "$list" "foxundermoon.shell-format"                      "Shell-format"
  code_install_ext "$list" "richie5um2.vscode-sort-json"                    "Sort JSON objects"
  code_install_ext "$list" "Tyriar.sort-lines"                              "Sort lines"
  code_install_ext "$list" "sensourceinc.vscode-sql-beautify"               "SQL Beautify"
  code_install_ext "$list" "sysoev.language-stylus"                         "Stylus"
  code_install_ext "$list" "cssho.vscode-svgviewer"                         "SVG Viewer"
  code_install_ext "$list" "bradlc.vscode-tailwindcss"                      "Tailwind CSS IntelliSense"
  code_install_ext "$list" "wayou.vscode-todo-highlight"                    "TODO Highlight"
  code_install_ext "$list" "minhthai.vscode-todo-parser"                    "TODO Parser"
  code_install_ext "$list" "octref.vetur"                                   "Vetur"
  code_install_ext "$list" "dunstontc.viml"                                 "Viml-syntax"
  code_install_ext "$list" "VisualStudioExptTeam.vscodeintellicode"         "Visual Studio IntelliCode"
  code_install_ext "$list" "dariofuzinato.vue-peek"                         "Vue Peek"
  code_install_ext "$list" "sdras.vue-vscode-snippets"                      "Vue Snippets"
  code_install_ext "$list" "WakaTime.vscode-wakatime"                       "WakaTime"
  code_install_ext "$list" "redhat.vscode-yaml"                             "YAML"
}

# -----------------------------------------------------------------------------

main
break_line
