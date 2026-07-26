status is-interactive || exit

if type -q starship
    if not test -r $__fish_cache_dir/starship_init.fish
        starship init fish >$__fish_cache_dir/starship_init.fish
    end
    source $__fish_cache_dir/starship_init.fish
else
    echo "starship is not installed"
end
