# Folder navigation
alias ... 'cd ../..'
alias .... 'cd ../../..'
alias ..... 'cd ../../../..'
alias ...... 'cd ../../../../..'

# Eza
alias ls 'eza --grid $EZA_PARAMS'
alias l 'eza --git-ignore --grid $EZA_PARAMS'
alias ll 'eza --all --header --long $EZA_PARAMS'
alias llm 'eza --all --header --long --sort=modified $EZA_PARAMS'
alias la 'eza -lbhHSa --icons'
alias lx 'eza -lbhHSa@ --icons'
alias lt 'eza --tree -L 3 $EZA_PARAMS'
alias tree 'eza --tree $EZA_PARAMS'

# Tmux
alias ta 'tmux attach -t'
alias ts 'tmux new-session -s'
alias tks 'tmux kill-server'
alias tmuxconf '$EDITOR $ZSH_TMUX_CONFIG'

# Tig
alias tis 'tig status'
alias til 'tig log'
alias tib 'tig blame -C'
alias tif 'tig reflog'
alias tia 'tig --all'

# Applications
alias copilot 'copilot --banner'
alias fkill 'bunx fkill-cli'
alias gitignore 'bunx --bun gitignore'
alias np 'bunx --bun np'
alias npkill 'bunx --bun npkill'
alias serve 'bunx serve'
alias taze 'bunx taze -r -w -I'
alias untun 'bunx untun'

switch $OS_RELEASE
    case darwin
        ##
    case linux

        # RAM Consumption Report
        alias ram 'free -h'
        alias ramf 'sudo sysctl -w vm.drop_caches=3'

        # Apps command
        alias trmdf "sudo update-alternatives --config x-terminal-emulator"

        # Flatpak apps
        alias ff 'flatpak run org.fontforge.FontForge'

        # Hardware
        alias mxm 'setxkbmap -model abnt -layout us -variant intl'

        switch $OS_DISTRO
            case arch

                # Repository management
                alias autoclean 'sudo yay -Scc --noconfirm && yay -Yc --noconfirm'
                alias update 'yay -Syu --noconfirm'

            case pop ubuntu

                # Repository management
                alias add 'sudo add-apt-repository -y'
                alias remove 'sudo apt-add-repository -r -y'

                # Install .deb files
                alias deb 'sudo dpkg -i --force-depends'

                # Nala (apt utils) upgrade command
                alias install 'sudo nala install -y'
                alias uninstall 'sudo nala remove --purge -y'

        end
end
