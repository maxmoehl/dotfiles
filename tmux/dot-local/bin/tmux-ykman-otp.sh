#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2025 Maximilian Moehl

set -exo pipefail

export PATH="${HOME}/.local/bin:${PATH}"

# xargs is used to strip the trailing new-line which ykman _always_ adds
ykman oath accounts code --single "${*}" | xargs echo -n | tmux load-buffer -b "${*}" -
