#!/usr/bin/env fish

#############
# CONSTANTS #
#############

function ConstConfigPath
    if set -q XDG_CONFIG_HOME
        echo $XDG_CONFIG_HOME/litellm.json
    else
        echo ~/.config/litellm.json
    end
end

function ConstSessionDir
    if set -q XDG_DATA_HOME
        echo $XDG_DATA_HOME/chat.fish
    else
        echo ~/.local/share/chat.fish
    end
end

function ConstDefaultModel
    echo sonnet-45
end

function ConstDefaultCurlOpts
    echo --no-progress-meter
    echo --fail-with-body
    echo --location
end

function ConstDefaultSystemPrompt
    echo 'You are a helpful assistant. Your output goes directly to a terminal
with light markdown rendering and syntax highlighting. Be brief, scrolling is
tedious and terminals have limited height. The user can attach files using @
those files will be printed at the end of the message and separated from the
rest of the content by the @@@FILES@@@ marker.'
end

function ConstTools
    jq -cn '[{
        "type": "function",
        "function": {
            "name": "curl",
            "description": "Retrieve the contentes of a website.",
            "parameters": {
                "type": "object",
                "properties": {
                    "url": {
                        "type": "string",
                        "description": "URL to retrieve, no options can be passed to cURL."
                    }
                },
                "required": ["url"]
            }
        }
    }, {
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
    }]'
end

###########
# GLOBALS #
###########

set -g Model (ConstDefaultModel)
set -g ApiUrl
set -g ApiKey

###########
# HELPERS #
###########

function log_error -a msg
    echo "error: $msg" >&2
end

function log_fatal -a msg code
    echo "fatal error: $msg" >&2
    if test -n "$code"
        exit $code
    else
        exit 1
    end
end

function vcurl
    if not set -q Verbose
        curl (ConstDefaultCurlOpts) $argv 2>&1
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

    curl --write-out '%{stderr}%{json}' (ConstDefaultCurlOpts) $argv $argv_opts $opts >$stdout_file 2>$stderr_file

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

function _md
    if command -q md
        md
    else if command -q bat
        bat --language markdown --paging never
    else
        cat
    end
end

############
# PRINTING #
############

function print_help
    echo "chat.fish - Minimal REPL to chat with LLMs

USAGE
    chat.fish [options] [args]

OPTIONS
    -c, --continue
        Continue the last conversation.

    -h, --help
        Show this help page.

    -m, --model <model>
        Select a model. Defaults to $(ConstDefaultModel).

    -r, --resume <name>
        Continue a named converstaion.

    -s, --system <message>
        Overwrite the default system prompt. Can only be set once, the last
        value will be used. Cannot be combined with --resume or --continue.

    -u, --user <message>
        Set the first user message, the message will be immediatly sent to the
        model and after the response has been received the conversation
        continues as usual. Cannot be combined with --resume or --continue.

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
        Retrieve the plain-text version of the given RFC from rfc-editor.org.

    curl <url>
        Retrieve the contents of a website. Will prompt the user to allow / deny
        the tool call.

CONFIGURATION
    Create ~/.config/litellm.json with:

        {
          \"url\": \"https://llm.example.com\",
          \"key\": \"sk-...\"
        }
"
end

function print_startup -a model session
    echo "
  ┌─────────────────────┐
  │ ><>  chat.fish  <>< │
  └─────────────────────┘

  Model:   $model
  Session: $(basename -s '.jsonl' $session)
"
end

function print_tool_call -a func args
    printf "\nTool call: %s(%s)\n" "$func" "$(echo "$args" | jq -r 'to_entries | map("\(.key)=\(.value)") | join(" ")')"
end

function print_assistant -a content
    printf '%s' "$content" | _md
end

function print_user -a content
    printf '> %s\n' "$(string split -f1 '@@@FILES@@@' "$content")"
end

######################
# MESSAGE FORMATTING #
######################

function format_user_message -a content
    begin
        printf "%s\n" "$content"

        set -l paths (string match -gar '@([a-zA-Z0-9/_.-]+)' $content)

        if test (count $paths) -gt 0
            printf "@@@FILES@@@\n"
        end

        for path in $paths
            if not test -f $path
                echo "warning: file not found: $path, skipping" >&2
                continue
            end

            echo "@$path"
            cat $path
            printf "\n\n"
        end
    end | jq -Rscn \
        '{role: "user", content: input}'
end

function format_assistant_message -a content
    jq -cn \
        --arg content "$content" \
        '{role: "assistant", content: $content}'
end

function format_system_message -a content
    jq -cn \
        --arg content "$content" \
        '{role: "system", content: $content}'
end

function format_tool_call -a tool_call
    jq -cn \
        --argjson tool_call "$tool_call" \
        '{role: "assistant", tool_calls: [$tool_call]}'
end

function format_tool_result -a id func content
    jq -cn \
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
        case curl
            tool_curl (echo $arguments | jq -r '.url')
        case man
            tool_man (echo $arguments | jq -r '.page')
        case rfc
            tool_rfc (echo $arguments | jq -r '.number')
        case '*'
            echo "unknown tool $tool_name" >&2
            return 1
    end
end

function tool_curl -a url
    read -l response -p "printf 'Allow tool call? [\e[4mY\e[24mes|\e[4mn\e[24mo] '"
    if string match -r '^(y|Y)' $response >/dev/null
        vcurl $url
    else
        echo "user denied tool use"
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

function mode_interactive -a session skip_prompt
    print_startup $Model $session

    # Replay previous messages if there are any.
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
    end <$session

    # REPL
    while true
        if test $skip_prompt = true
            set skip_prompt false
        else
            read -l -P "> " user_input
            or break

            set -l user_input (string trim "$user_input")
            if test -z "$user_input"
                continue
            end

            if string match -q '.*' -- "$user_input"
                cmd (string split ' ' "$user_input")
                continue
            end

            format_user_message "$user_input" >>$session
        end

        set -l payload (jq -cn \
            --arg model $Model \
            --argjson tools (ConstTools) \
            --slurpfile messages $session \
            '{model: $model, tools: $tools, messages: $messages}')

        set -l response (litellm "/v1/chat/completions" $payload); or begin
            log_fatal "failed to retrieve response: $response"
        end

        set -l content "$(echo "$response" | jq -r '.choices[0].message.content // empty')"
        set -l tool_call (echo "$response" | jq -c '.choices[0].message.tool_calls[0] // empty')

        if test -n "$content"
            format_assistant_message "$content" >>$session
            print_assistant "$content"
        else if test -n "$tool_call"
            set -l id (echo "$tool_call" | jq -r '.id')
            set -l func (echo "$tool_call" | jq -r '.function.name')
            set -l args (echo "$tool_call" | jq -r '.function.arguments')

            print_tool_call "$func" "$args"

            # TODO: error handling?
            set -l content "$(tool $func $args)"

            format_tool_call "$tool_call" >>$session
            format_tool_result "$id" "$func" "$content" >>$session

            set skip_prompt true
        else
            log_fatal "got empty response from model"
        end
    end
end

function main
    argparse --strict-longopts \
        --name chat.fish \
        --max-args 0 \
        --exclusive continue,resume,user \
        --exclusive continue,resume,system \
        (fish_opt -s c -l continue) \
        (fish_opt -s h -l help) \
        (fish_opt -s m -l model --required-val) \
        (fish_opt -s r -l resume --required-val) \
        (fish_opt -s s -l system --required-val) \
        (fish_opt -s u -l user --required-val) \
        (fish_opt -s v -l verbose) \
        -- $argv; or exit 1

    if set -q _flag_verbose
        set -g Verbose true
    end

    if set -q _flag_help
        print_help
        exit
    end

    if not test -f (ConstConfigPath)
        log_fatal "config file $(ConstConfigPath) does not exist"
    end

    set -g ApiUrl (jq -r '.url // empty' <(ConstConfigPath))
    set -g ApiKey (jq -r '.key // empty' <(ConstConfigPath))

    if test -z "$ApiUrl"; or test -z "$ApiKey"
        log_fatal "API URL and API key must be set"
    end

    if set -q _flag_model
        set -g Model $_flag_model
    end

    set -f system_prompt "$(ConstDefaultSystemPrompt)"
    if set -q _flag_system
        set -f system_prompt "$_flag_system"
    end

    set -f session
    if set -q _flag_continue
        set session "$(ConstSessionDir)/$(ls -t (ConstSessionDir) | head -n1)"
        if string match -qv 0 $pipestatus
            log_fatal "failed to retrieve latest conversation"
        else if test -z "$session"
            log_fatal "no session found to continue"
        end
    else if set -q _flag_resume
        set session "$(ConstSessionDir)/$_flag_resume.jsonl"
        if not test -f $session
            log_fatal "session $_flag_resume does not exit"
        end
    else
        set session "$(ConstSessionDir)/$(generate_session_name).jsonl"
        if test -f $session
            log_fatal "randomly generate session already exists, please try again :)"
        end
    end

    if not set -q session
        log_fatal "unable to determine session"
    end

    if not test -f $session
        format_system_message "$system_prompt" >>$session
    end

    if set -q _flag_user
        format_user_message "$_flag_user"
        mode_interactive $session true
    else
        mode_interactive $session false
    end
end

main $argv
