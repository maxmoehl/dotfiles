function fish_right_prompt
    set -g __fish_git_prompt_showcolorhints true
    set -l last_status $status
    set -l stat
    if test $last_status -ne 0
        set stat "$(set_color red)$last_status$(set_color normal)"
    end
    string join ' ' -- (prompt_pwd) (fish_git_prompt '%s') $stat
end
