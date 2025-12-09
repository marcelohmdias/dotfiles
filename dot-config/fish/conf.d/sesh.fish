status is-interactive || exit

if type -q sesh
    if not test -r $__fish_cache_dir/sesh_init.fish
        sesh completion fish >$__fish_cache_dir/sesh_init.fish
    end
    source $__fish_cache_dir/sesh_init.fish
else
    echo "sesh is not installed"
end
