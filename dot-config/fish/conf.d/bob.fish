status is-interactive || exit

if type -q bob
    if not test -r $__fish_cache_dir/bob_init.fish
        bob complete fish >$__fish_cache_dir/bob_init.fish
    end
    source $__fish_cache_dir/bob_init.fish
else
    echo "bob is not installed"
end
