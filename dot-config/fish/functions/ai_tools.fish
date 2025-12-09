function ai_tools --description 'Launch AI CLI tools via fzf menu'
    set -l AI_CLI_TOOLS claude codex copilot crush gemini opencode

    set -l chosen (printf '%s\n' $AI_CLI_TOOLS | fzf --border-label ' 󰚩 AI Tools ')

    if test -z "$chosen"
        return
    end

    switch $chosen
        case copilot
            exec copilot --banner
        case '*'
            exec $chosen
    end
end
