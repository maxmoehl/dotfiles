#!/usr/bin/env fish

# Ensure we can find tmux if it exists.
fish_add_path --global --move ~/.local/bin

if status is-interactive && command -sq tmux && not set -q TMUX
    exec tmux new-session -A -s main
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
