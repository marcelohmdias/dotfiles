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

    execute "sudo install -o root -g root -m 644 packages.microsoft.gpg /usr/share/keyrings/ &> /dev/null" "Install Key"

    sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] $repository stable main" > $file' &> /dev/null

    update_apt

    install_package "code" "VS Code"

    sleep 0.5

  fi

  list="$(code --list-extensions)"

  break_line
  print_msg_sub_info "VS Code Extension"

  install_code_ext "$list" "kaicataldo.alpenglow-monokai"                   "Alpenglow Monokai"
  install_code_ext "$list" "apollographql.vscode-apollo"                    "Apollo GraphQL"
  install_code_ext "$list" "ms-vscode.atom-keybindings"                     "Atom Keymap"
  install_code_ext "$list" "formulahendry.auto-close-tag"                   "Auto Close Tag"
  install_code_ext "$list" "formulahendry.auto-rename-tag"                  "Auto Rename Tag"
  install_code_ext "$list" "HookyQR.beautify"                               "Beautify"
  install_code_ext "$list" "alefragnani.Bookmarks"                          "Bookmarks"
  install_code_ext "$list" "wmaurer.change-case"                            "Change-case"
  install_code_ext "$list" "softwaredotcom.swdc-vscode"                     "Code Time"
  install_code_ext "$list" "kisstkondoros.vscode-codemetrics"               "CodeMetrics"
  install_code_ext "$list" "anseki.vscode-color"                            "Color Picker"
  install_code_ext "$list" "kamikillerto.vscode-colorize"                   "Colorize"
  install_code_ext "$list" "ExodiusStudios.comment-anchors"                 "Comment Anchors"
  install_code_ext "$list" "pranaygp.vscode-css-peek"                       "CSS Peek"
  install_code_ext "$list" "Dart-Code.dart-code"                            "Dart"
  install_code_ext "$list" "msjsdiag.debugger-for-chrome"                   "Debugger for Chrome"
  install_code_ext "$list" "ms-azuretools.vscode-docker"                    "Docker"
  install_code_ext "$list" "joelday.docthis"                                "Document This"
  install_code_ext "$list" "mikestead.dotenv"                               "DotENV"
  install_code_ext "$list" "EditorConfig.EditorConfig"                      "EditorConfig"
  install_code_ext "$list" "mjmcloug.vscode-elixir"                         "Elixir"
  install_code_ext "$list" "dbaeumer.vscode-eslint"                         "Eslint"
  install_code_ext "$list" "file-icons.file-icons"                          "File-icons"
  install_code_ext "$list" "abierbaum.vscode-file-peek"                     "File Peek"
  install_code_ext "$list" "mkxml.vscode-filesize"                          "Filesize"
  install_code_ext "$list" "Dart-Code.flutter"                              "Flutter"
  install_code_ext "$list" "tombonnike.vscode-status-bar-format-toggle"     "Formatting Toggle"
  install_code_ext "$list" "donjayamanne.githistory"                        "Git History"
  install_code_ext "$list" "lamartire.git-indicators"                       "Git Indicators"
  install_code_ext "$list" "GitHub.vscode-pull-request-github"              "GitHub Pull Requests"
  install_code_ext "$list" "codezombiech.gitignore"                         "Gitignore"
  install_code_ext "$list" "eamodio.gitlens"                                "GitLens"
  install_code_ext "$list" "ms-vscode.Go"                                   "Go"
  install_code_ext "$list" "kumar-harsh.graphql-for-vscode"                 "GraphQL"
  install_code_ext "$list" "vincaslt.highlight-matching-tag"                "Highlight Matching Tag"
  install_code_ext "$list" "kisstkondoros.vscode-gutter-preview"            "Image preview"
  install_code_ext "$list" "wix.vscode-import-cost"                         "Import Cost"
  install_code_ext "$list" "Zignd.html-css-class-completion"                "IntelliSense for CSS class names in HTML"
  install_code_ext "$list" "Orta.vscode-jest"                               "Jest"
  install_code_ext "$list" "MS-vsliveshare.vsliveshare"                     "Live Share"
  install_code_ext "$list" "yzhang.markdown-all-in-one"                     "Markdown All in One"
  install_code_ext "$list" "eg2.vscode-npm-script"                          "NPM"
  install_code_ext "$list" "karanba.npm-helper"                             "NPM Helper"
  install_code_ext "$list" "christian-kohler.npm-intellisense"              "NPM Intellisense"
  install_code_ext "$list" "IBM.output-colorizer"                           "Output Colorizer"
  install_code_ext "$list" "ryu1kn.partial-diff"                            "Partial Diff"
  install_code_ext "$list" "christian-kohler.path-intellisense"             "Path Intellisense"
  install_code_ext "$list" "johnpapa.vscode-peacock"                        "Peacock"
  install_code_ext "$list" "pnp.polacode"                                   "Polacode"
  install_code_ext "$list" "MS-CEINTL.vscode-language-pack-pt-BR"           "Portuguese (Brazil) Language Pack"
  install_code_ext "$list" "esbenp.prettier-vscode"                         "Prettier - Code formatter"
  install_code_ext "$list" "mohsen1.prettify-json"                          "Prettify JSON"
  install_code_ext "$list" "alefragnani.project-manager"                    "Project Manager"
  install_code_ext "$list" "ms-python.python"                               "Python"
  install_code_ext "$list" "chrmarti.regex"                                 "Regex Previewer"
  install_code_ext "$list" "le0zh.vscode-regexp-preivew"                    "Regex Previewer and Editor"
  install_code_ext "$list" "jakob101.RelativePath"                          "Relative Path"
  install_code_ext "$list" "ms-vscode-remote.remote-containers"             "Remote - Containers"
  install_code_ext "$list" "ms-vscode-remote.remote-ssh"                    "Remote - SSH"
  install_code_ext "$list" "Syler.sass-indented"                            "Sass"
  install_code_ext "$list" "Shan.code-settings-sync"                        "Settings Sync"
  install_code_ext "$list" "foxundermoon.shell-format"                      "Shell-format"
  install_code_ext "$list" "richie5um2.vscode-sort-json"                    "Sort JSON objects"
  install_code_ext "$list" "Tyriar.sort-lines"                              "Sort lines"
  install_code_ext "$list" "sensourceinc.vscode-sql-beautify"               "SQL Beautify"
  install_code_ext "$list" "sysoev.language-stylus"                         "Stylus"
  install_code_ext "$list" "cssho.vscode-svgviewer"                         "SVG Viewer"
  install_code_ext "$list" "bradlc.vscode-tailwindcss"                      "Tailwind CSS IntelliSense"
  install_code_ext "$list" "wayou.vscode-todo-highlight"                    "TODO Highlight"
  install_code_ext "$list" "minhthai.vscode-todo-parser"                    "TODO Parser"
  install_code_ext "$list" "octref.vetur"                                   "Vetur"
  install_code_ext "$list" "dunstontc.viml"                                 "Viml-syntax"
  install_code_ext "$list" "VisualStudioExptTeam.vscodeintellicode"         "Visual Studio IntelliCode"
  install_code_ext "$list" "dariofuzinato.vue-peek"                         "Vue Peek"
  install_code_ext "$list" "sdras.vue-vscode-snippets"                      "Vue Snippets"
  install_code_ext "$list" "WakaTime.vscode-wakatime"                       "WakaTime"
  install_code_ext "$list" "redhat.vscode-yaml"                             "YAML"
}

# -----------------------------------------------------------------------------

main
break_line
