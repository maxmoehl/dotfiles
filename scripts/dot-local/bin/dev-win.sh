#!/bin/sh
# Usage: dev-win.sh DIR
# Opens a new tmux window named after the directory, with 3 panes:
#   left top    -> vim
#   left bottom -> shell (height 80)
#   right       -> pi agent (width 80)
set -eu

if [[ $# -ne 1 ]]; then
  echo "usage: dev-win.sh DIR" >&2
  exit 1
fi

dir="$(cd "$1" && pwd)"
name="$(basename "$dir")"

left_top=$(tmux new-window -n "$name" -c "$dir" -P -F '#{pane_id}')
right=$(tmux split-window -h -t "$left_top" -c "$dir" -l 100 -P -F '#{pane_id}')
tmux split-window -v -t "$left_top" -c "$dir" -l 20

tmux send-keys   -t "$right"    "pi"  Enter
tmux send-keys   -t "$left_top" "vim" Enter
tmux select-pane -t "$left_top"
