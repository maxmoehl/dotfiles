function fish_title
    # An override for the current command is passed as the first parameter.
    # This is used by `fg` to show the true process name, among others.
    if set -q argv[1]
        set -f command $argv[1]
    else if test "$(status current-command)" != fish
        set -f command (status current-command)
    end

    if set -q command
        echo -- (prompt_pwd -d 1 -D 1) "│" (string sub -l 50 -- $command)
    else
        echo -- (prompt_pwd -d 1 -D 1)
    end
end
