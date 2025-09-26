#!/usr/bin/env fish

set -gx XDG_CONFIG_HOME ~/.config
set -gx XDG_CACHE_HOME ~/.cache

set -gx GOCACHE ~/.cache/go
set -gx GOMODCACHE ~/.cache/go-mod
set -gx GOBIN ~/.local/bin

set -gx TT_HOME_DIR ~/.config/tt

if test -x /opt/homebrew/bin/brew
    eval (/opt/homebrew/bin/brew shellenv fish)
end

# user paths always take precedence
fish_add_path -g ~/.local/bin
fish_add_path -g ~/.local/share/cargo/bin

if command -q hx
    set -gx EDITOR hx
    abbr -a -- edit hx
else
    set -gx EDITOR vim
    abbr -a -- edit vim
end
