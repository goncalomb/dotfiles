#!/bin/bash

set -euo pipefail
cd -- "$(dirname -- "$0")"

PDIR=tmp/profile.d
mkdir -p "$PDIR"

if command -v python3 >/dev/null; then
    PYTHON_USER_BASE_BIN="$(python3 -m site --user-base)/bin"
    if [[ ":$PATH:" != *":$PYTHON_USER_BASE_BIN:"* ]]; then
        echo "export PATH=\"\$PATH:$PYTHON_USER_BASE_BIN\"" >"$PDIR/python-user-base-bin.sh"
        PATH="$PATH:$PYTHON_USER_BASE_BIN" # update current PATH
    fi
    if command -v activate-global-python-argcomplete >/dev/null; then
        activate-global-python-argcomplete --dest=- >"$PDIR/python-argcomplete.sh"
    fi
fi

# homebrew

BREW_PREFIX=/opt/homebrew
if [ -f "$BREW_PREFIX/bin/brew" ]; then
    if ! command -v brew >/dev/null; then
        "$BREW_PREFIX/bin/brew" shellenv >"$PDIR/homebrew.sh"
    fi
    if [ -f "$BREW_PREFIX/etc/profile.d/bash_completion.sh" ]; then
        echo ". $BREW_PREFIX/etc/profile.d/bash_completion.sh" >"$PDIR/homebrew-bash-completion.sh"
    fi
fi
