function fish_prompt
    set -l prepend_space false

    echo -n (set_color red)
    if test -n "$SSH_CONNECTION"
        set prepend_space true
        echo -n "[$(prompt_hostname)]"
    end

    if test $SHLVL -gt 1
        set prepend_space true
        echo -n "[lvl=$(math $SHLVL - 1)]"
    end
    echo -n (set_color normal)

    if $prepend_space
        echo -n ' '
    end

    echo -n (set_color blue)
    if fish_is_root_user
        echo -n '# '
    else
        echo -n '$ '
    end
    echo -n (set_color normal)
end
