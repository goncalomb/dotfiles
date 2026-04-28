#!/usr/bin/env bash

# /// dotfiles
# description = "install asdf locally"
# author = "goncalomb"
# tags = []
# ///

set -e
cd -- "$(dirname -- "$0")"

# https://asdf-vm.com/guide/getting-started.html

mkdir -p tmp/bin
cd tmp/bin

UNAME_S="$(uname -s)"
UNAME_M="$(uname -m)"
case "$UNAME_M" in
    i386|i686) ARCH="386" ;;
    x86_64) ARCH="amd64" ;;
    aarch64|arm64) ARCH="arm64" ;;
    *) ARCH="$UNAME_M" ;;
esac

echo "finding latest asdf release..."
VERSION="$(curl -fsSL "https://api.github.com/repos/asdf-vm/asdf/releases/latest" | grep '"tag_name"' | sed 's/.*"tag_name": *"\([^"]*\)".*/\1/')"
[ -z "$VERSION" ] && echo "error: failed to find latest asdf release" >&2 && exit 1

NAME="asdf-${VERSION}-${UNAME_S,,}-${ARCH}"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

echo "downloading '$NAME'..."
curl -fsSL -o "$TMP_DIR/$NAME.tar.gz" "https://github.com/asdf-vm/asdf/releases/download/$VERSION/$NAME.tar.gz"

echo "extracting to '$(pwd)'..."
tar -xzf "$TMP_DIR/$NAME.tar.gz" asdf

if command -v file >/dev/null; then
    file asdf
else
    echo "done"
fi
