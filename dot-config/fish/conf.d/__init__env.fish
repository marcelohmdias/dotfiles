set -gx ATUIN_NOBIND true

set -gx BAT_THEME Catppuccin-frappe

set -Ux BUN_CONFIG_FORCE_IPV4 1

set -gx EDITOR nvim

set -gx EZA_PARAMS --git --icons --group --group-directories-first --time-style=long-iso --color-scale=all

set -gx FORCE_COLOR true

set -gx FZF_DEFAULT_OPTS (printf '%s ' \
    '--ansi' \
    '--bind=btab:up,tab:down' \
    '--border=rounded' \
    '--color=bg+:-1,bg:-1' \
    '--color=fg:#b5bfe2,fg+:#c6d0f5' \
    '--color=hl:#e78284,hl+:#e78284' \
    '--color=border:#c6d0f5' \
    '--color=header:#8caaee' \
    '--color=info:#ca9ee6' \
    '--color=label:#c6d0f5' \
    '--color=marker:#f2d5cf' \
    '--color=pointer:#8caaee' \
    '--color=prompt:#ca9ee6' \
    '--color=scrollbar:#949cbb' \
    '--color=spinner:#f2d5cf' \
    '--gutter=" "' \
    '--height=50%' \
    '--info=inline-right' \
    '--margin=0' \
    '--padding=0' \
    '--pointer="▶"' \
    '--prompt="  "' \
    '--reverse' \
    '--tmux=60%' | string collect)

set -gx FZF_ALT_C_OPTS (printf '%s ' \
    '--border-label "  Last Commands "' \
    '--preview "tree -C {}"' \
    '--tac' | string collect)

set -gx FZF_COMPLETION_TRIGGER //

set -gx FZF_CTRL_R_OPTS (printf '%s ' \
    '--bind="ctrl-/:toggle-preview"' \
    '--bind="ctrl-y:execute-silent(echo -n {2..} | xclip -selection clipboard)+abort"' \
    '--border-label="  Last Commands "' \
    '--header="󰅍 Press: ^y copy command into clipboard \n\n"' \
    '--preview="echo {}"' \
    '--preview-window="down:3:hidden:wrap"' | string collect)

set -gx FZF_CTRL_T_OPTS (printf '%s ' \
    '--bind="ctrl-/:change-preview-window(down|hidden|)"' \
    '--border-label="  Last Commands "' \
    '--header="󰆏 Select to copy \n\n"' \
    '--preview="bat -n --color=always {} --theme=Catppuccin-frappe"' \
    '--tac' | string collect)

set -gx GIT_SSH_COMMAND ssh -o "HostName=ssh.github.com" -o "Port=443" -o "IdentityFile=~/.ssh/id_rsa" -o "User=git"

set -gx GLAMOUR_STYLE $HOME/.config/glamour/frappe.json

set -gx GO_DIR $HOME/.go

set -gx GOPATH $GO_DIR

set -gx HOMEBREW_NO_AUTO_UPDATE 1

set -gx HOMEBREW_NO_INSTALL_CLEANUP 1

set -gx HOMEBREW_NO_ANALYTICS 1

set -Ux LANG en_US.UTF-8

set -Ux LC_ALL en_US.UTF-8

set -Ux LD_LIBRARY_PATH $HOME/.local/lib $LD_LIBRARY_PATH

set -Ux MANGOHUD_CONFIGFILE $HOME/.config/MangoHud/MangoHud.conf

set -gx NPM_CONFIG_USERCONFIG $HOME/.config/npm/.npmrc

set -gx OPENSPEC_TELEMETRY 0

set -gx STARSHIP_CONFIG $HOME/.config/starship/starship.toml

set -gx STARSHIP_SHELL fish

set -gx TERM xterm-256color

set -Ux TMPDIR $HOME/.cache/tmp

set -gx VISUAL nvim
