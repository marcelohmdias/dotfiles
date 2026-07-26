status is-interactive || exit

if type -q mise
    mise activate fish --shims | source
    mise activate fish | source
    if not test -r $__fish_cache_dir/mise_init.fish
        mise completion fish >$__fish_cache_dir/mise_init.fish
    end
    source $__fish_cache_dir/mise_init.fish
else
    echo "mise is not installed"
end
