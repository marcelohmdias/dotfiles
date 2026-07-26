status is-interactive || exit

if type -q just
    if not test -r $__fish_cache_dir/just_init.fish
        just --completions fish >$__fish_cache_dir/just_init.fish
    end
    source $__fish_cache_dir/just_init.fish
else
    echo "just is not installed"
end
