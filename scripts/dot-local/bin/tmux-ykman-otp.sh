#!/usr/bin/env bash

set -exo pipefail

export PATH="${HOME}/.local/bin:${PATH}"

# xargs is used to strip the trailing new-line which ykman _always_ adds
ykman oath accounts code --single "${*}" | xargs echo -n | tmux load-buffer -b "${*}" -
