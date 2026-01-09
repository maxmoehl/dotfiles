#!/usr/bin/env fish

# Ensure we can find all of our binaries.
fish_add_path --global --move ~/.local/bin

if status is-interactive
    if command -q tmux; and not set -q TMUX; and not set -q SSH_CONNECTION
        exec tmux new-session -A -s main
    end

    if command -q atuin
        atuin init fish --disable-up-arrow | source
    end
end

set -gx XDG_CONFIG_HOME ~/.config
set -gx XDG_CACHE_HOME ~/.cache

set -gx GOCACHE ~/.cache/go
set -gx GOMODCACHE ~/.cache/go-mod
set -gx GOBIN ~/.local/bin

set -gx TT_HOME_DIR ~/.config/tt

if test -x /opt/homebrew/bin/brew
    eval (/opt/homebrew/bin/brew shellenv fish)
end

fish_add_path --global ~/.local/share/cargo/bin
# This should _always_ be the first path to check.
fish_add_path --global --move ~/.local/bin

if command -sq hx
    set -gx EDITOR hx
    abbr -a -- edit hx
else
    set -gx EDITOR vim
    abbr -a -- edit vim
end

# Disable system-wide functions I don't like.
functions -e \
    alias \
    grep \
    l \
    la \
    ll
