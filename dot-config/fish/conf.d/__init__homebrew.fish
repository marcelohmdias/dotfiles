if test "$OS_DISTRO" = "arch"
  exit
end

# Find the brew command
set brewcmds (
    path filter \
        $HOME/.homebrew/bin/brew \
        $HOME/.linuxbrew/bin/brew \
        /var/home/linuxbrew/.linuxbrew/bin/brew \
        /opt/homebrew/bin/brew \
        /usr/local/bin/brew
    )
if test (count $brewcmds) -eq 0
    echo >&2 "brew command not found. Install from https://brew.sh"
    return 1
end
$brewcmds[1] shellenv | source

# These should now be set, but we can do this as a failsafe
set -q HOMEBREW_PREFIX || set HOMEBREW_PREFIX (brew --prefix)
set -q HOMEBREW_REPOSITORY || set HOMEBREW_REPOSITORY (brew --repository)

# If the brew path is owned by another user, wrap it so brew commands
# are executed as the brew owner.
if test (uname) = "Darwin"
  set -gx HOMEBREW_OWNER (stat -f "%Su" $HOMEBREW_PREFIX)
else
  set HOMEBREW_OWNER (stat -c '%U' /home/linuxbrew/.linuxbrew 2>/dev/null)
end

if test "$HOMEBREW_OWNER" != (whoami)
    function brew --description 'Wrap brew with sudo for multi-user systems'
        sudo -Hu $HOMEBREW_OWNER brew $argv
    end
end

# Ensure manpath is set to something so we can add to it.
set -q MANPATH || set -gx MANPATH ''

# Add keg-only apps
set -q HOMEBREW_KEG_ONLY_APPS || set -U HOMEBREW_KEG_ONLY_APPS ruby curl sqlite
for app in $HOMEBREW_KEG_ONLY_APPS
    if test -d "$HOMEBREW_PREFIX/opt/$app/bin"
        fish_add_path "$HOMEBREW_PREFIX/opt/$app/bin"
        set MANPATH "$HOMEBREW_PREFIX/opt/$app/share/man" $MANPATH
    end
end

# Add fish completions
if test -e "$HOMEBREW_PREFIX/share/fish/completions"
    set --append fish_complete_path "$HOMEBREW_PREFIX/share/fish/completions"
end

# Add command not found handler (brew command-not-found-init)
set HOMEBREW_COMMAND_NOT_FOUND_HANDLER $HOMEBREW_REPOSITORY/Library/Homebrew/command-not-found/handler.fish
if test -f $HOMEBREW_COMMAND_NOT_FOUND_HANDLER
    source $HOMEBREW_COMMAND_NOT_FOUND_HANDLER
end

# Other homebrew vars.
set -q HOMEBREW_NO_ANALYTICS || set -gx HOMEBREW_NO_ANALYTICS 1
