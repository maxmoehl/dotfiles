#!/usr/bin/env fish

set -g ConfigPath "$HOME/.config/litellm.json"
set -g DefaultCurlOpts --no-progress-meter --fail-with-body --location

function log_error -a msg
    echo "error: $msg" >&2
end

function load_config
    if not test -f $ConfigPath
        return
    end

    set -g ApiUrl (jq -r '.url // empty' <$ConfigPath)
    set -g ApiKey (jq -r '.key // empty' <$ConfigPath)

    set -l conf_model (jq -r '.model // empty' <$ConfigPath)
    if test -n "$conf_model"
        set -g Model $conf_model
    end
end

function vcurl
    if not set -q Verbose
        curl $DefaultCurlOpts $argv 2>&1
        return $status
    end

    argparse --name vcurl --strict-longopts 'data=' 'header=' -- $argv

    set -l method GET
    if set -q _flag_data
        set method POST
    end

    set -l tmpdir (mktemp -d)
    set -l stdout_file $tmpdir/out
    set -l stderr_file $tmpdir/err

    echo "[REQUEST] $method $argv[1]" 1>&2
    if set -q _flag_data
        echo "$_flag_data" | jq 1>&2
    else
    end

    curl --write-out '%{stderr}%{json}' $DefaultCurlOpts $argv $argv_opts $opts >$stdout_file 2>$stderr_file

    set -l response_code (jq -r '.response_code' <$stderr_file)
    set -l content_type (jq -r '.content_type' <$stderr_file)
    set -l error_msg (jq -r '.errormsg' <$stderr_file)
    set -l exit_code (jq -r '.exitcode' <$stderr_file)

    echo "[RESPONSE] $response_code" >&2
    if test "$error_msg" != null
        echo "$error_msg"
        cat "$stdout_file"
        return 1
    else
        switch $content_type
            case 'application/json*'
                jq <$stdout_file >&2
            case '*'
                cat $stdout_file >&2
        end
    end

    cat $stdout_file

    rm -rf $tmpdir

    return $exit_code
end

function litellm -a url_path body
    set -l url "$ApiUrl$url_path"
    if test -n "$body"
        vcurl $url \
            --header "Content-Type: application/json" \
            --header "Authorization: Bearer $ApiKey" \
            --data "$body"
    else
        vcurl "$url" \
            --header "Authorization: Bearer $ApiKey"
    end
end

function generate_session_name
    set -l adjectives \
        admiring brave clever determined eager focused gallant \
        hungry inspiring jolly keen lucid mystic nostalgic \
        optimistic peaceful quirky relaxed stoic trusting \
        vibrant wonderful zealous

    set -l names \
        albattani babbage curie darwin einstein feynman \
        galileo hawking hopper johnson knuth lovelace \
        maxwell newton pasteur planck ritchie shannon \
        tesla turing volhard wozniak yalo

    echo "$(random choice $adjectives)_$(random choice $names)"
end

#####################
# OUTPUT FORMATTING #
#####################

function print_help
    echo 'chat.fish - Minimal REPL to chat with LLMs

USAGE
    chat.fish [options] [args]

OPTIONS
    -c, --continue
        Continue the last conversation.

    -h, --help
        Show this help page.

    -m, --model <model>
        Use the given model, overrides environment variable and config file
        properties. See CONFIGURATION for more information.

    -r, --resume <name>
        Continue a named converstaion.

    -v, --verbose
        Print verbose output like all requests and responses as they are sent
        to the API.

INTERACTIVE USE
    Besides typing text and the most basic navigation and text editing you can
    attach files by using @/file/path. The contents of the file will be appended
    to the end of your prompt for the LLM to inspect.

    In the REPL any messages that starts with a '.' is considered a command. The
    available commands are:

    .help
        Show a list of available commands.

    .model [<model>]
        Switch the used model throughout the conversation. Without a model print
        the model currently in use.

    .models
        List all available models.

    .verbose [(on|off)]
        Switch verbose mode on or off. Without an argument it prints the current
        setting.

TOOLS
    A number of tools are registered in the conversation to allow the model to
    retrieve technical information and ensure accurate responses.

    man <page>
        Retrieve a plain-text version of the given manual page using the local
        man command. If no page was found it will try to retrieve a version from
        Arch Linux at man.archlinux.org.

    rfc <number>
        Retrieve the plain-text version of  the given RFC from rfc-editor.org.

CONFIGURATION
    Create ~/.config/litellm.json with:

        {
          "url": "https://llm.example.com",
          "key": "sk-..."
        }
'
end

function print_startup
    echo "
  ┌─────────────────────┐
  │ ><>  chat.fish  <>< │
  └─────────────────────┘

  Model:   $Model
  Session: $(basename -s '.jsonl' $Session)
"
end

function print_tool_call -a func args
    printf "\nTool call: %s(%s)\n" "$func" "$(echo "$args" | jq -r 'to_entries | map("\(.key)=\(.value)") | join(" ")')"
end

function print_assistant -a content
    printf '%s' "$content" | md
end

function print_user -a content
    printf '> %s\n' "$(string split -f1 '@@@FILES@@@' "$content")"
end

######################
# MESSAGE FORMATTING #
######################

function append_user_message -a content
    begin
        printf "%s\n" "$content"
        printf "@@@FILES@@@\n"

        for path in (string match -gar '@([a-zA-Z0-9/_.-]+)' $content)
            if not test -f $path
                echo "warning: file not found: $path, skipping" >&2
                continue
            end

            echo "@$path"
            cat $path
            printf "\n\n"
        end
    end | jq -Rscn >>$Session \
        '{role: "user", content: input}'
end

function append_assistant_message -a content
    jq -cn >>$Session \
        --arg content "$content" \
        '{role: "assistant", content: $content}'
end

function append_system_message -a content
    jq -cn >>$Session \
        --arg content "$content" \
        '{role: "system", content: $content}'
end

function append_tool_call -a tool_call
    jq -cn >>$Session \
        --argjson tool_call "$tool_call" \
        '{role: "assistant", tool_calls: [$tool_call]}'
end

function append_tool_result -a id func content
    jq -cn >>$Session \
        --arg call_id "$id" \
        --arg name "$func" \
        --arg content "$content" \
        '{role: "tool", tool_call_id: $call_id, name: $name, content: $content}'
end

########################
# INTERACTIVE COMMANDS #
########################

function cmd -a command
    set -e argv[1]

    switch $command
        case '.help'
            echo "Available commands: .help .model .models .verbose"
        case '.model'
            cmd_model $argv[1]
        case '.models'
            cmd_models
        case '.verbose'
            cmd_verbose $argv[1]
        case '*'
            log_error "unknown command $command"
    end
end

function cmd_model -a model
    if test -n "$model"
        set -g Model $model
    else
        echo "$Model"
    end
end

function cmd_models
    litellm /v1/models | jq -r '.data[].id' | column
end

function cmd_verbose -a val
    switch $val
        case on
            set -g Verbose true
        case off
            set -e -g Verbose
        case ''
            if set -q Verbose
                echo on
            else
                echo off
            end
        case '*'
            log_error "invalid value given, allowed values: on, off"
    end
end

################
# TOOL CALLING #
################

function tool -a tool_name arguments
    switch $tool_name
        case man
            tool_man (echo $arguments | jq -r '.page')
        case rfc
            tool_rfc (echo $arguments | jq -r '.number')
        case '*'
            echo "unknown tool $tool_name" >&2
            return 1
    end
end

function tool_man -a page
    man $page 2>/dev/null
    or vcurl "https://man.archlinux.org/man/$page.txt"
end

function tool_rfc -a number
    vcurl "https://www.rfc-editor.org/rfc/rfc$number.txt"
end

###############
# MAIN SCRIPT #
###############

argparse --strict-longopts \
    --name chat.fish \
    --max-args 0 \
    c/continue \
    h/help \
    'm/model=' \
    'r/resume=' \
    v/verbose \
    -- $argv; or exit 1

load_config

set -q _flag_verbose; and set -g Verbose true
set -q _flag_model; and set -g Model $_flag_model

set -q -g Model; or set -g Model sonnet-45

if set -q _flag_help
    print_help
    exit
end

set -g SessionDir "$HOME/.local/share/chat.fish"
mkdir -p $SessionDir

if set -q _flag_continue
    set -g Session "$SessionDir/$(ls -t $SessionDir | head -n1)"
    if string match -qv 0 $pipestatus
        log_error "failed to retrieve latest conversation"
        exit 1
    end
else if set -q _flag_resume
    set -g Session "$SessionDir/$_flag_resume.jsonl"
else
    set -g Session "$SessionDir/$(generate_session_name).jsonl"
    if test -f $Session
        log_error "randomly generate session already exists, please try again :)"
        exit 1
    end
end

if not set -q Session
    log_error "unable to determine session"
    exit 1
end

if test -z "$ApiUrl"; or test -z "$ApiKey"
    log_error "LITELLM_URL and LITELLM_API_KEY must be set"
    exit 1
end

print_startup

set -g Tools (jq -cn '[{
    "type": "function",
    "function": {
        "name": "man",
        "description": "Retrieve contents of a manual page.",
        "parameters": {
            "type": "object",
            "properties": {
                "page": {
                    "type": "string",
                    "description": "Page that should be retrieved. Examples: curl, curl.1, man"
                }
            },
            "required": ["page"]
        }
    }
}, {
    "type": "function",
    "function": {
        "name": "rfc",
        "description": "Retrieve contents of a RFC.",
        "parameters": {
            "type": "object",
            "properties": {
                "number": {
                    "type": "integer",
                    "description": "Number of the RFC to retrieve."
                }
            },
            "required": ["number"]
        }
    }
}]')

set -g SystemPrompt 'You are a helpful assistant. Your
output goes directly to a terminal with light markdown rendering and syntax
highlighting. Be brief, scrolling is tedious and terminals have limited height.
The user can attach files using @ those files will be printed at the end of the
message and separated from the rest of the content by the @@@FILES@@@ marker.'

if not test -f $Session
    # Start of a new session, ensure system prompt is persisted.
    append_system_message "$SystemPrompt"
else
    # Resuming an existing session, replay the previous messages.
    while read -l line
        switch (echo $line | jq -r '.role')
            case user
                print_user "$(echo "$line" | jq -r '.content')"
            case assistant
                set -l content "$(echo "$line" | jq -r '.content // empty')"
                set -l tool_call (echo "$line" | jq -c '.tool_calls[0] // empty')

                if test -n "$content"
                    print_assistant "$content"
                else if test -n "$tool_call"
                    print_tool_call \
                        "$(echo "$tool_call" | jq -r '.function.name')" \
                        "$(echo "$tool_call" | jq -r '.function.arguments')"
                end
        end
        # case tool is ignored, that's only for the assistant to see.
    end <$Session
end

while true
    if set -q skip_prompt
        set -e -g skip_prompt
    else
        read -l -P "> " user_input
        or break

        set user_input (string trim "$user_input")
        if test -z "$user_input"
            continue
        end

        if string match -q '.*' -- "$user_input"
            cmd (string split ' ' "$user_input")
            continue
        end

        append_user_message "$user_input"
    end

    set -l payload (jq -cn \
        --arg model "$Model" \
        --argjson tools "$Tools" \
        --slurpfile messages $Session \
        '{model: $model, tools: $tools, messages: $messages}')

    set -l response (litellm "/v1/chat/completions" $payload); or begin
        log_error "failed to retrieve response: $response"
        exit 1
    end

    set -l content "$(echo "$response" | jq -r '.choices[0].message.content // empty')"
    set -l tool_call (echo "$response" | jq -c '.choices[0].message.tool_calls[0] // empty')

    if test -n "$content"
        append_assistant_message "$content"
        print_assistant "$content"
    else if test -n "$tool_call"
        set -l id (echo "$tool_call" | jq -r '.id')
        set -l func (echo "$tool_call" | jq -r '.function.name')
        set -l args (echo "$tool_call" | jq -r '.function.arguments')

        # TODO: error handling?
        set -l content "$(tool $func $args)"

        append_tool_call "$tool_call"
        append_tool_result "$id" "$func" "$content"

        print_tool_call "$func" "$args"

        set -g skip_prompt true
    else
        log_error "got empty response from model"
        exit 1
    end
end
