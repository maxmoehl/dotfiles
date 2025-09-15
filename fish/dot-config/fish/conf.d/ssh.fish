#!/usr/bin/env fish

# location for control sockets
if ! test -d ~/.local/run/ssh
    install -m 0700 -d ~/.local/run/ssh
end
