#!/usr/bin/env bash

# /// dotfiles
# description = "install mise locally"
# author = "goncalomb"
# tags = []
# ///

set -euo pipefail
cd -- "$(dirname -- "$0")"

# https://mise.jdx.dev/installing-mise.html

mkdir -p tmp/bin tmp/profile.d
MISE_BIN="$(pwd)/tmp/bin/mise"

# install or update mise
if [ ! -f "$MISE_BIN" ]; then
    curl -fsSL https://mise.run | MISE_INSTALL_PATH="$MISE_BIN" sh
else
    "$MISE_BIN" self-update
fi

# deactivate to avoid deactivation script appearing in the new activation
# mise detects if it is already activated add extra stuff to `mise activate`
if [ -n "${__MISE_EXE:-}" ]; then
    eval "$("$MISE_BIN" deactivate)"
fi

{
    # self-destruct, removes activation if mise is missing
    cat <<EOF
if [ ! -f "$MISE_BIN" ]; then
    rm -f "\${BASH_SOURCE[0]}" # self-destruct
    return
fi
EOF
    # normal mise activation
    "$MISE_BIN" activate
} >tmp/profile.d/mise.sh
