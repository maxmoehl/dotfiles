#!/usr/bin/env fish

function load_config -a config_file
    if test -f "$config_file"
        while read -l line
            set -l line (string trim "$line")
            if test -z "$line"; or string match -q '#*' "$line"
                continue
            end
            set -l parts (string split -m 1 '=' "$line")
            if test (count $parts) -eq 2
                set -l key (string trim $parts[1])
                set -l val (string trim $parts[2])
                set val (string trim -c '"' $val)
                set val (string trim -c "'" $val)
                switch $key
                    case LITELLM_API_KEY
                        set -g ApiKey $val
                    case LITELLM_URL
                        set -g ApiUrl $val
                    case LITELLM_MODEL
                        set -g Model $val
                end
            end
        end <"$config_file"
    end

    if test -z "$ApiUrl"; or test -z "$ApiKey"
        echo "Error: LITELLM_URL and LITELLM_API_KEY must be set in $config_file" >&2
        exit 1
    end

    if test -z "$Model"
        set -g Model sonnet-45
    end
end

function format_message -a role content
    jq -cn \
        --arg role "$role" \
        --arg content "$content" \
        '{"role":$role,"content":$content}'
end

function llm_curl -a url_path body
    set -l url "$ApiUrl$url_path"
    if set -q Verbose
        echo "[REQUEST] POST $url" >&2
    end
    if set -q Verbose && test -n "$body"
        echo "$body" | jq . >&2
    end

    set -l response
    if test -n "$body"
        set response (curl -sSf $url \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $ApiKey" \
            -d "$body")
    else
        set response (curl -sSf "$url" \
            -H "Authorization: Bearer $ApiKey")
    end

    if set -q Verbose
        echo "[RESPONSE]" >&2
        if test -n "$response"
            echo "$response" | jq . >&2
        end
    end

    if test -z "$response"
        echo "Error: Failed to get response from API" >&2
        return 1
    end

    echo "$response"
end

function process_command -a command
    set -e argv[1]

    switch $command
        case '.help'
            echo "Available commands: .help .model .models"
        case '.model'
            set -g Model $argv[1]
        case '.models'
            set -l response (llm_curl /v1/models); or return
            echo $response | jq -r '.data[].id' | column
        case '*'
            echo "Error: unknown command $command" >&2
    end
end

# TODO: resume & continue with persistent sessions.
# TODO: model flag to override config

argparse v/verbose -- $argv
or exit 1

if set -q _flag_verbose
    set -g Verbose true
end

load_config "$HOME/.config/litellm.conf"

set -l system_prompt "You are a helpful assistant. Your output goes directly" \
    "to a terminal without any markdown rendering or syntax highlighting." \
    "Keep responses plain text, avoid code fences and markdown formatting." \
    "Indent code to separate it from the rest of the text. Be brief," \
    "scrolling is tedious and terminals have limited height."
set -g messages (format_message 'system' (string join " " $system_prompt))

while true
    read -l -P "> " user_input
    or break

    set user_input (string trim $user_input)
    if test -z "$user_input"
        continue
    end

    if string match -q '.*' -- $user_input
        process_command (string split ' ' $user_input)
        continue
    end

    set -a messages (format_message "user" "$user_input")

    set -l payload (jq -cn \
        --arg model "$Model" \
        --argjson messages "[$(string join ',' $messages)]" \
        '{model: $model, messages: $messages}')

    set -l response (llm_curl "/v1/chat/completions" $payload)
    or set -e messages[-1] && continue

    set -l content "$(echo "$response" | jq -r '.choices[0].message.content // empty')"
    if test -z "$content"
        echo "Error: Empty response from API" >&2
        set -e messages[-1]
        continue
    end

    set -a messages (format_message "assistant" "$content")

    echo ""
    echo "$content"
    echo ""
end
