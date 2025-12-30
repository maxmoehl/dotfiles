function todo
    rg --color=always --line-number --no-heading --ignore-case \
        '(#|//|<!--) ?TODO' \
        | fzf --ansi \
        --color light \
        --delimiter : \
        --preview 'bat --color=always {1} --highlight-line {2}' \
        --preview-window '60%,border-bottom,+{2}+3/3,~3' \
        --header "Return: Helix; ^O: Open" \
        --layout reverse \
        --bind 'enter:become(hx {1}:{2}),ctrl-o:execute-silent(git gh open file {1} {2}),c:execute-silent(git gh open -p file {1} {2} | pbcopy)'
end
