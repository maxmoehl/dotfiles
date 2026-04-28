command! JsonMinify let b:json_minified = 1

function s:JsonRead()
    if line('$') == 1
        silent %!jq --monochrome-output
        let b:json_minified = 1
    endif
endfunction

function s:JsonWrite()
    if get(b:, 'json_minified')
        silent %!jq --monochrome-output --compact-output
    endif
endfunction

function s:JsonWritePost()
    if get(b:, 'json_minified')
        silent %!jq --monochrome-output
        set nomodified
    endif
endfunction

augroup json_min
    autocmd!
    autocmd BufReadPost  *.json call s:JsonRead()
    autocmd BufWritePre  *.json call s:JsonWrite()
    autocmd BufWritePost *.json call s:JsonWritePost()
augroup END
