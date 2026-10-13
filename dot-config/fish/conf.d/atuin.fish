status is-interactive || exit

if type -q atuin
    set -l tool_version (atuin --version 2>/dev/null | string match -r '[\d.]+' | head -1)
    if test -z "$tool_version"
        set tool_version "dev"
    end
    set -l cache_file $__fish_cache_dir/atuin_init_$tool_version.fish
    if not test -r $cache_file
        atuin init fish >$cache_file
    end
    source $cache_file
else
    echo "atuin is not installed"
end
