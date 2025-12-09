set -Ux ATUIN_NOBIND true

set -Ux BAT_THEME Catppuccin-frappe

set -Ux EDITOR nvim

set -Ux EZA_PARAMS --git --icons --group --group-directories-first --time-style=long-iso --color-scale=all

set -Ux FORCE_COLOR true

set -Ux FZF_DEFAULT_OPTS (printf '%s ' \
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

set -Ux FZF_ALT_C_OPTS (printf '%s ' \
    '--border-label "  Last Commands "' \
    '--preview "tree -C {}"' \
    '--tac' | string collect)

set -Ux FZF_COMPLETION_TRIGGER //

set -Ux FZF_CTRL_R_OPTS (printf '%s ' \
    '--bind="ctrl-/:toggle-preview"' \
    '--bind="ctrl-y:execute-silent(echo -n {2..} | xclip -selection clipboard)+abort"' \
    '--border-label="  Last Commands "' \
    '--header="󰅍 Press: ^y copy command into clipboard \n\n"' \
    '--preview="echo {}"' \
    '--preview-window="down:3:hidden:wrap"' | string collect)

set -Ux FZF_CTRL_T_OPTS (printf '%s ' \
    '--bind="ctrl-/:change-preview-window(down|hidden|)"' \
    '--border-label="  Last Commands "' \
    '--header="󰆏 Select to copy \n\n"' \
    '--preview="bat -n --color=always {} --theme=Catppuccin-frappe"' \
    '--tac' | string collect)

set -Ux GIT_SSH_COMMAND ssh -o "HostName=ssh.github.com" -o "Port=443" -o "IdentityFile=~/.ssh/id_rsa" -o "User=git"

set -Ux GLAMOUR_STYLE $HOME/.config/glamour/frappe.json

set -Ux GO_DIR $HOME/.go

set -Ux GOPATH $GO_DIR

set -Ux MISE_NPM_BUN true

set -Ux NPM_CONFIG_USERCONFIG $HOME/.config/npm/.npmrc

set -Ux STARSHIP_CONFIG $HOME/.config/starship/starship.toml

set -Ux STARSHIP_SHELL fish

set -Ux TERM xterm-256color

set -Ux VISUAL nvim
