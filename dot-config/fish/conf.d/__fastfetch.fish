# Show fastfetch early in interactive sessions (except vscode/zed)
if status is-interactive
    if test "$TERM_PROGRAM" != vscode; and test "$TERM_PROGRAM" != zed
        fastfetch
    end
end
