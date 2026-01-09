#!/usr/bin/env fish

if set -q XDG_DATA_HOME
    set -g SessionDir $XDG_DATA_HOME/chat.fish
else
    set -g SessionDir ~/.local/share/chat.fish
end

complete -c chat.fish \
    --no-files

complete -c chat.fish \
    -s c -l continue \
    -d "Continue the last conversation"

complete -c chat.fish \
    -s h -l help \
    -d "Show command help"

complete -c chat.fish \
    -s m -l model \
    -d "Specify model to use" \
    -a '(chat.fish list-models)' \
    --exclusive

complete -c chat.fish \
    -s r -l resume \
    -d "Resume a previous session" \
    -a '(chat.fish list-sessions)' \
    --exclusive

complete -c chat.fish \
    -s s -l system \
    -d "Overwrite the system prompt" \
    --exclusive

complete -c chat.fish \
    -s u -l user \
    -d "Specify the first user prompt" \
    --exclusive

complete -c chat.fish \
    -s v -l verbose \
    -d "Enable verbose request logging"
