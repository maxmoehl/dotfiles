function rcp --wraps rsync
    rsync --progress --partial --archive --verbose --compress $argv
end
