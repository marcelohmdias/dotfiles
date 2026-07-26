status is-interactive || exit

if type -q fzf
    if not test -r $__fish_cache_dir/fzf_init.fish
        fzf --fish >$__fish_cache_dir/fzf_init.fish
    end
    source $__fish_cache_dir/fzf_init.fish
else
    echo "fzf is not installed"
end
