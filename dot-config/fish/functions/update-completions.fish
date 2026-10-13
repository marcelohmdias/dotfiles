function update-completions --description "Regenerate tool completions after updates"
    set -l completion_dir $__fish_config_dir/completions
    set -l tools bob bun deno gh just rustup sesh
    set -l updated 0
    
    for tool in $tools
        if type -q $tool
            echo -n "Updating $tool completions... "
            switch $tool
                case bob
                    bob complete fish > $completion_dir/bob.fish
                case bun
                    bun completions > $completion_dir/bun.fish
                case deno
                    deno completions fish > $completion_dir/deno.fish
                case gh
                    gh completion --shell fish > $completion_dir/gh.fish
                case just
                    just --completions fish > $completion_dir/just.fish
                case rustup
                    rustup completions fish rustup > $completion_dir/rustup.fish
                case sesh
                    sesh completion fish > $completion_dir/sesh.fish
            end
            set updated (math $updated + 1)
            echo "done"
        end
    end
    
    echo "Updated $updated completion files"
end
