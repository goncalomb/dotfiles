#!/bin/bash

# /// dotfiles
# description = "for macOS, installs bash from homebrew to replace the outdated version bundled with xcode, set it as the current user's SHELL"
# author = "goncalomb"
# tags = ["caution"]
# ///

set -euo pipefail

[ "$(uname -s)" != "Darwin" ] && echo "error: not macOS (Darwin)" >&2 && exit 1
! command -v brew >/dev/null && echo "error: Homebrew not found" >&2 && exit 1

BREW_BASH="$(brew --prefix)/bin/bash"
USER_SHELL=$(dscl -plist . -read "/Users/$USER" UserShell | xpath -q -e "/plist/dict//string[1]/text()")

[ -z "$USER_SHELL" ] && echo "error: could not determine user shell" >&2 && exit 1

echo "BREW_BASH=$BREW_BASH"
echo "USER_SHELL=$USER_SHELL"
echo "SHELL=$SHELL"

if [ ! -f "$BREW_BASH" ]; then
    brew install bash bash-completion@2
fi

if [ ! -f "$HOME/.bash_profile" ]; then
    echo "Creating minimal '~/.bash_profile' (was missing)..."
    cat >"$HOME/.bash_profile" <<'EOF'
# This file was created when setting bash as the default shell.
# https://github.com/goncalomb/dotfiles
if [ -z "$LANG" ]; then
    export LANG=en_US.UTF-8
fi
if [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
fi
EOF
fi

if ! grep -qxF "$BREW_BASH" /private/etc/shells; then
    echo "Adding '$BREW_BASH' to '/private/etc/shells' (using sudo)..."
    echo "$BREW_BASH" | sudo tee -a /private/etc/shells >/dev/null
fi

if [ "$USER_SHELL" != "$BREW_BASH" ]; then
    echo "Changing user shell to '$BREW_BASH' (using chsh)..."
    chsh -s "$BREW_BASH"
    echo "Done. Restart your terminal."
elif [ "$SHELL" != "$BREW_BASH" ]; then
    echo "OK. User shell is set but the current terminal is not using it."
else
    echo "OK."
fi
