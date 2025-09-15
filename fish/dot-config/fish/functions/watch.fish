function watch
    if command -q viddy
        command viddy --disable_mouse --disable_auto_save $argv
    else
        command watch $argv
    end
end
