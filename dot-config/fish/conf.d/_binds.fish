bind -M default \ck tsm
bind -M insert \ck tsm
bind -M visual \ck tsm

bind -M default \cx 'clear; source ~/.config/fish/config.fish; commandline -f repaint'
bind -M insert \cx 'clear; source ~/.config/fish/config.fish; commandline -f repaint'

bind -M default \el 'clear; commandline -f repaint'
bind -M insert \el 'clear; commandline -f repaint'

bind -M default \er _atuin_search
bind -M insert \er _atuin_search

bind -M default \e\ca tmux_toggle_bar
bind -M insert \e\ca tmux_toggle_bar

bind -M default \e\cs tmux_toggle_position
bind -M insert \e\cs tmux_toggle_position
