status is-interactive || exit

if type -q gh
    if not test -r $__fish_cache_dir/gh_init.fish
        gh completion --shell fish >$__fish_cache_dir/gh_init.fish
    end
    source $__fish_cache_dir/gh_init.fish
else
    echo "gh is not installed"
end
