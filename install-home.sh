#!/usr/bin/env bash

# /// dotfiles
# description = "automated installation, updates and installs system packages, installs dotfiles (see above)"
# author = "goncalomb"
# tags = ["caution"]
# ///

set -euo pipefail
cd -- "$(dirname -- "$0")"

echo70() {
    # old bash versions (i.e. macOS) don't support \e
    echo -e "\033[7m$@\033[0m"
}

confirm() {
	read -r -p "${1:-Are you sure} (y/n)? " YESNO
	[[ "$YESNO" =~ ^[yY] ]]
}

APT_CMD=
APT_BASE_PACKAGES=()
export IH_PLATFORM=$(uname -s)
export IH_DOTFILES_DIR="$HOME/dotfiles"

if [ -f "README.md" ] && [[ "$(head -n1 README.md)" == *dotfiles* ]]; then
    # looks like we are in the dotfiles repo, use it
    IH_DOTFILES_DIR="$(pwd)"
fi

if [[ "${PREFIX:-}" == *"/com.termux/"* ]]; then
    APT_CMD="pkg"
    APT_BASE_PACKAGES+=(git python)
    IH_PLATFORM="Termux"
elif [[ "$IH_PLATFORM" == "Linux" ]]; then
    APT_CMD="apt"
    APT_BASE_PACKAGES+=(git python3 python3-pip)
elif [[ "$IH_PLATFORM" == "Darwin" ]]; then
    :
else
    echo "error: unsupported platform '$IH_PLATFORM'" >&2 && exit 1
fi

cd "$HOME"

echo "goncalomb's home install script"
echo
uname -a
echo
echo "HOME=$HOME"
echo "USER=${USER:-}" # unbound on Termux
echo "IH_PLATFORM=$IH_PLATFORM"
echo "IH_DOTFILES_DIR=$IH_DOTFILES_DIR"
echo

if [ -z "${DOTFILES_GONCALOMB:-}" ]; then
    confirm "Do you understand what this script does? Continue" || exit 1
    echo
fi

if [ -n "$APT_CMD" ]; then
    echo70 update system
    $APT_CMD update -y
    $APT_CMD upgrade -y
    $APT_CMD remove -y --auto-remove
    if [ "${#APT_BASE_PACKAGES[@]}" -gt 0 ]; then
        echo70 install base packages
        $APT_CMD install -y "${APT_BASE_PACKAGES[@]}"
    fi
fi

if [ "$IH_PLATFORM" = "Darwin" ]; then
    if ! command -v brew >/dev/null; then
        echo70 install brew
        bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    # On macOS, Homebrew installs the command-line tools for Xcode,
    # so git and python are available after this point.
fi

echo70 install dotfiles
if [ ! -d "$IH_DOTFILES_DIR" ]; then
    git clone --depth=1 https://github.com/goncalomb/dotfiles.git "$IH_DOTFILES_DIR"
fi
"$IH_DOTFILES_DIR/install.sh"
"$IH_DOTFILES_DIR/install-profile.sh"
