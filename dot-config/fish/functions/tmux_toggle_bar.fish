function tmux_toggle_bar --description 'Toggle tmux status bar'
    set -Ux TMUX_STATUS_BAR_STATE (tmux show -g status | choose -f ' ' 1)

    if test "$TMUX_STATUS_BAR_STATE" = on
        set -Ux TMUX_STATUS_BAR_STATE off
    else
        set -Ux TMUX_STATUS_BAR_STATE on
    end

    tmux set -g status "$TMUX_STATUS_BAR_STATE"
end
