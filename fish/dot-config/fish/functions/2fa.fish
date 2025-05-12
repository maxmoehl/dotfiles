function 2fa
    ykman oath accounts code --single $argv | tee /dev/stderr | pbcopy
end
