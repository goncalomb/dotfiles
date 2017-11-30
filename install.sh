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

DIR_BIN="$DIR/bin"
DIR_BIN_TERMUX="$DIR/bin/termux"

if [[ "$PREFIX" == *"/com.termux/"* ]]; then
	echo "Running on a Termux environment!"
	echo "Patching executable scripts..."
	mkdir "$DIR_BIN_TERMUX" 2> /dev/null
	for f in "$DIR_BIN/"*; do
		if [[ -f "$f" && -x "$f" ]]; then
			i=$(sed -nE "s/^#\!.*\/[sx]?bin\/(.*)/\1/p" "$f" | head -n 1)
			if [[ -n "$i" ]]; then
				b=$(basename "$f")
				cat << EOF > "$DIR_BIN_TERMUX/$b"
#!$PREFIX/bin/bash
DIR=\$(cd -P -- "\$(dirname -- "\${BASH_SOURCE[0]}")" && pwd -P)
$PREFIX/bin/$i "\$DIR/../$b" "\$@"
EOF
				chmod +x "$DIR_BIN_TERMUX/$b"
			fi
		fi
	done
	echo "Creating shortcuts..."
	mkdir "$DIR_HOME/.shortcuts" 2> /dev/null
	echo "$DIR/bin/termux/logdata && killall com.termux"  >"$DIR_HOME/.shortcuts/LogText"
	echo "$DIR/bin/termux/logdata --event && killall com.termux" > "$DIR_HOME/.shortcuts/LogEvent"
	echo "(killall sshd && echo \"sshd stopped\") || (sshd && echo \"sshd started\")" > "$DIR_HOME/.shortcuts/StartStopSSHD"
	echo
fi

echo "Installing dotfiles..."
create_dotfile_link "bashrc"

if confirm_remove "$DIR_HOME/.gitconfig"; then
	echo
	truncate --size 0 "$DIR_HOME/.gitconfig"
	git config --global include.path "~/$DIR_RELATIVE/gitconfig"
	git config --global core.excludesfile "~/$DIR_RELATIVE/gitignore"
	gh-set-user
fi
