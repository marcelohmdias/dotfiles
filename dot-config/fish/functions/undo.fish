function undo --description 'Delete command of history using fzf'
    set -l picked (history | fzf -m)
    if test -z "$picked"
        return
    end
    builtin history delete --exact --case-sensitive -- $picked
    builtin history save
end
