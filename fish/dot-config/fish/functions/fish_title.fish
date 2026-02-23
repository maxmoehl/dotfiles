function fish_title
    # An override for the current command is passed as the first parameter.
    # This is used by `fg` to show the true process name, among others.
    if set -q argv[1]
        set -f command $argv[1]
    else if test "$(status current-command)" != fish
        set -f command (status current-command)
    end

    if set -q command
        if test (string sub -l 4 $command) = "ssh "
            echo -- (ssh_dst $command)
        else
            echo -- (prompt_pwd -d 1 -D 1) "│" (string sub -l 50 -- $command)
        end
    else
        echo -- (prompt_pwd -d 1 -D 1)
    end
end

function ssh_dst
    # echo 1>&2 "called ssh_dst '$argv' ($(count $argv))"
    argparse --name=ssh 4 6 A a C f G g K k M N n q s T t V v X x Y y B= b= c= D= E= e= F= I= i= J= L= l= m= O= o= P= p= R= S= W= w= -- (string split ' ' $argv)
    # echo 1>&2 "result '$argv' ($(count $argv))"
    echo $argv[2]
end
