function tmux_toggle_position --description "Toggle tmux status bar position"
    set -Ux TMUX_POSITION_BAR_STATE (tmux show -g status-position | choose -f ' ' 1)

    if test "$TMUX_POSITION_BAR_STATE" = top
        set -Ux TMUX_POSITION_BAR_STATE bottom
    else
        set -Ux TMUX_POSITION_BAR_STATE top
    end

    tmux set -g status-position "$TMUX_POSITION_BAR_STATE"
end
