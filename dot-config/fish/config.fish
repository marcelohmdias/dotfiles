#
# ░█▀▀░▀█▀░█▀▀░█░█
# ░█▀▀░░█░░▀▀█░█▀█
# ░▀░░░▀▀▀░▀▀▀░▀░▀
#
# A smart and user-friendly command line
# https://fishshell.com/

# Set initial working directory.

set -g IWD $PWD

if status is-interactive
    # Commands to run in interactive sessions can go here
    if test "$TERM_PROGRAM" != vscode; and test "$TERM_PROGRAM" != zed
        fastfetch
    end
end
