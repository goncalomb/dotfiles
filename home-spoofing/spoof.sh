#!/bin/bash

if [ ! -z "$HOME_IS_SPOOFED" ]; then
	echo "HOME=$HOME" >&2
	echo "HOME is already spoofed, aborting." >&2
	exit 1
fi

DIR=$(cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
NEW_HOME=$(cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd -P)

function echo_debug {
	if [ ! -z "$HOME_SPOOFING_DEBUG" ]; then echo $1; fi
}

if [ ! -f "$DIR/preload.so" ]; then
	echo_debug "[home-spoofing] Compiling 'preload.so'..."
	gcc -Wall -shared -fPIC -ldl "$DIR/preload.c" -o "$DIR/preload.so" || exit 1
fi

echo_debug "[home-spoofing] HOME=$NEW_HOME"

cd "$NEW_HOME"

env \
HOME="$NEW_HOME" \
HOME_IS_SPOOFED="$HOME" \
LD_PRELOAD="$DIR/preload.so" \
"$@"
