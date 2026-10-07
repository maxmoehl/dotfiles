#!/usr/bin/env bash
# Usage: dev-win.sh <directory>
# Opens a new tmux window named after the directory, with 3 panes:
#   left top    -> vim
#   left bottom -> shell (height 80)
#   right       -> pi agent (width 80)
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "usage: $(basename "$0") <directory>" >&2
  exit 1
fi

dir="$(cd "$1" && pwd)"
name="$(basename "$dir")"

left_top=$(tmux new-window -n "$name" -c "$dir" -P -F '#{pane_id}')
right=$(tmux split-window -h -t "$left_top" -c "$dir" -l 100 -P -F '#{pane_id}')
left_bottom=$(tmux split-window -v -t "$left_top" -c "$dir" -l 20 -P -F '#{pane_id}')

tmux send-keys -t "$right"    "pi"  Enter
if [[ $# -ge 2 ]]; then
  tmux send-keys -t "$left_top" "vim -c 'GHReview $2'" Enter
else
  tmux send-keys -t "$left_top" "vim" Enter
fi

# Focus the vim pane
tmux select-pane -t "$left_top"
