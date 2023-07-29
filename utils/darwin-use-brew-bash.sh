#!/bin/bash

set -euo pipefail

[ "$(uname -s)" != "Darwin" ] && echo "not a darwin os" && exit 1
! command -v brew >/dev/null && echo "'brew' not found" && exit 1

BREW_BASH="$(brew --prefix)/bin/bash"

if [ ! -f "$BREW_BASH" ]; then
    brew install bash bash-completion
fi

if ! grep -qxF "$BREW_BASH" /private/etc/shells; then
    echo "adding '$BREW_BASH' to '/private/etc/shells' (using sudo)"
    echo "$BREW_BASH" | sudo tee -a /private/etc/shells >/dev/null
fi

if [ "$SHELL" != "$BREW_BASH" ]; then
    echo "changing shell to '$BREW_BASH' (using chsh)"
    chsh -s "$BREW_BASH"
    echo "restart your terminal"
fi
