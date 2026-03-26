function alias
    if test (count $argv) -ne 1
        echo "alias: expected one argument but got $(count $argv)" >&2
        return 1
    end

    set args (string split -m 1 "=" -- $argv) ""

    if test -z "$args[1]"
        echo "alias: name cannot be empty" >&2
        return 1
    else if test -z "$args[2]"
        echo "alias: body cannot be empty" >&2
        return 1
    end

    abbr -a -- $args[1] $args[2]
end
