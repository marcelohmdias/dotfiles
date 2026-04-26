# Set XDG basedirs.
# https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
set -q XDG_CONFIG_HOME; or set -Ux XDG_CONFIG_HOME $HOME/.config
set -q XDG_DATA_HOME; or set -Ux XDG_DATA_HOME $HOME/.local/share
set -q XDG_STATE_HOME; or set -Ux XDG_STATE_HOME $HOME/.local/state
set -q XDG_CACHE_HOME; or set -Ux XDG_CACHE_HOME $HOME/.cache
for xdgdir in (path filter -vd $XDG_CONFIG_HOME $XDG_DATA_HOME $XDG_STATE_HOME $XDG_CACHE_HOME)
    mkdir -p $xdgdir
end

# Allow subdirs for functions and completions.
set fish_function_path (path resolve $__fish_config_dir/functions/*/) $fish_function_path
set fish_complete_path (path resolve $__fish_config_dir/completions/*/) $fish_complete_path

# Setup caching.
if not set -q __fish_cache_dir
    if set -q XDG_CACHE_HOME
        set -U __fish_cache_dir $XDG_CACHE_HOME/fish
    else
        set -U __fish_cache_dir $HOME/.cache/fish
    end
end
test -d $__fish_cache_dir; or mkdir -p $__fish_cache_dir

# Remove expired cache files.
find $__fish_cache_dir -name '*.fish' -type f -mmin +1200 -delete

# Fish settings
set -U fish_greeting # disable fish greeting
set -U fish_key_bindings fish_vi_key_bindings

# OS env detection
set -U OS_RELEASE (uname | tr '[:upper:]' '[:lower:]')

switch $OS_RELEASE
    case darwin
        set -U OS_DISTRO mac
    case linux
        set -U OS_DISTRO (grep -P '^ID=' /etc/os-release | cut -d '=' -f 2 | xargs)
end

# Add bin directories to path.
set -g prepath (
    path filter \
        $HOME/.local/bin \
        $HOME/.local/share/mise/install \
        $HOME/.dotfiles/bin \
        $HOME/.local/share/bob/nvim-bin \
        $HOME/.local/share/flatpak/exports/bin
)

fish_add_path --prepend --move $prepath
