if type -q mise
    if status is-interactive
        mise activate fish | source
    else
        mise activate fish --shims | source
    end
    if not test -r $__fish_cache_dir/mise_init.fish
        mise completion fish >$__fish_cache_dir/mise_init.fish
    end
    source $__fish_cache_dir/mise_init.fish
else
    echo "mise is not installed"
end
