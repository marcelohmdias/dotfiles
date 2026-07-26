function tsm --description 'Connect to a tmux session using fzf and sesh'
    set -x session (sesh list -i | fzf)
    if test -z "$session"
        commandline --function repaint
        return 22
    end
    sesh connect "$session"
end
