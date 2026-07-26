status is-interactive || exit

if type -q deno
    if not test -r $__fish_cache_dir/deno_init.fish
        deno completions fish >$__fish_cache_dir/deno_init.fish
    end
    source $__fish_cache_dir/deno_init.fish
else
    echo "deno is not installed"
end
