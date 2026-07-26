status is-interactive || exit

if type -q bun
    if not test -r $__fish_cache_dir/bun_init.fish
        bun completions >$__fish_cache_dir/bun_init.fish
    end
    source $__fish_cache_dir/bun_init.fish
else
    echo "bun is not installed"
end
