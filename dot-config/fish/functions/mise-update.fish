function mise-update --description "Update mise tools and regenerate completions"
    mise update $argv
    update-completions
end
