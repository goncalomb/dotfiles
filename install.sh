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

function confirm_remove {
	if [ -e "$1" ]; then
		if ! confirm "$(basename "$1") already exists on HOME, replace"; then
			false; return
		fi
		rm "$1"; return
	fi
	true; return
}

function create_dotfile_link {
	LINK="$DIR_HOME/.$1"
	if confirm_remove "$LINK"; then
		ln -sT "$DIR_RELATIVE/$1" "$LINK"
	fi
}

echo "Installing dotfiles..."

bashrc-zone remove goncalomb-dotfiles
bashrc-zone add goncalomb-dotfiles << EOF
if [ -f "$DIR/bashrc" ]; then
	. "$DIR/bashrc"
fi
EOF

if confirm_remove "$DIR_HOME/.gitconfig"; then
	echo
	truncate --size 0 "$DIR_HOME/.gitconfig"
	git config --global include.path "~/$DIR_RELATIVE/gitconfig"
	git config --global core.excludesfile "~/$DIR_RELATIVE/gitignore"
fi
