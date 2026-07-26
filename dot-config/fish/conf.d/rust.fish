status is-interactive || exit

if type -q rustup
    if not test -r $__fish_cache_dir/rustup_init.fish
        rustup completions fish rustup >$__fish_cache_dir/rustup_init.fish
    end
    source $__fish_cache_dir/rustup_init.fish
else
    echo "rustup is not installed"
end
