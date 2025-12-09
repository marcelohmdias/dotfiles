status is-interactive || exit

if type -q mise
    if not test -r $__fish_cache_dir/mise_init.fish
        mise activate fish >$__fish_cache_dir/mise_init.fish
    end
    source $__fish_cache_dir/mise_init.fish
else
    echo "mise is not installed"
end
