status is-interactive || exit

if type -q direnv
    if not test -r $__fish_cache_dir/direnv_init.fish
        direnv hook fish >$__fish_cache_dir/direnv_init.fish
    end
    source $__fish_cache_dir/direnv_init.fish
else
    echo "direnv is not installed"
end
