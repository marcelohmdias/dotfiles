function vcm
    set -l items default LazyVim
    set chosen (printf "%s\n" $items | fzf --border-label "  Neovim Config " --height=40% --tmux=30%)

    if test -z "$chosen"
        echo "Nothing selected"
        return
    end

    switch $chosen
        case default
            set chosen nvim
        case LazyVim
            set chosen lazyvim
    end

    env NVIM_APPNAME=$chosen nvim $argv
end
