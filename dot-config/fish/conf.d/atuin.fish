status is-interactive || exit

if type -q atuin
    if not test -r $__fish_cache_dir/atuin_init.fish
        atuin init fish >$__fish_cache_dir/atuin_init.fish
    end
    source $__fish_cache_dir/atuin_init.fish
else
    echo "atuin is not installed"
end
