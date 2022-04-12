#!/bin/bash

DIR=$(cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
DIR_PARENT=$(cd -P -- "$(dirname -- "$DIR")" && pwd -P)
DIR_HOME=$(cd -P -- "$HOME" && pwd -P)

source "$DIR/bashrc"

if [ -z "$DIR_HOME" ]; then
	echo "Invalid HOME directory."
	exit
elif [[ "${DIR:0:${#DIR_HOME}+1}" != "$DIR_HOME/" ]]; then
	echo "The 'dotfiles' directory must be placed somewhere on your home directory."
	exit
fi

DIR_RELATIVE=${DIR:${#DIR_HOME}+1}

echo "    home directory: $DIR_HOME"
echo "dotfiles directory: $DIR"
echo "     relative path: $DIR_RELATIVE"
echo

echo "installing dotfiles..."

echo "appending to '~/.bashrc'"
bashrc-zone remove goncalomb-dotfiles
bashrc-zone add goncalomb-dotfiles << EOF
if [ -f "$DIR/bashrc" ]; then
	. "$DIR/bashrc"
fi
EOF

echo "setting git config 'include.path'"
echo "setting git config 'core.excludesfile'"
git config --global --unset-all include.path "~/$DIR_RELATIVE/gitconfig"
git config --global --unset-all core.excludesfile "~/$DIR_RELATIVE/gitignore"
git config --global --add include.path "~/$DIR_RELATIVE/gitconfig"
git config --global --add core.excludesfile "~/$DIR_RELATIVE/gitignore"
