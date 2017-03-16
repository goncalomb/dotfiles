#!/bin/bash

if [ ! -z "$HOME_IS_SPOOFED" ]; then
	echo "HOME=$HOME" >&2
	echo "HOME is already spoofed, aborting." >&2
	exit 1
fi

DIR=$(cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
NEW_HOME=$(cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd -P)

SYSTEM_HASH=$(sha1sum <(uname -a) | cut -d' ' -f1)
SYSTEM_HASH_FILE="$DIR/system-hash.txt"

function echo_debug {
	if [ ! -z "$HOME_SPOOFING_DEBUG" ]; then echo $1; fi
}

if [[ -f "$DIR/preload.so" ]]; then
	if [[ "$DIR/preload.c" -nt "$DIR/preload.so" ]]; then
		echo_debug "[home-spoofing] Code change, will compile 'preload.so'."
		rm "$DIR/preload.so"
	elif [[ ! -f "$SYSTEM_HASH_FILE" || "$SYSTEM_HASH" != "$(<"$SYSTEM_HASH_FILE")" ]]; then
		echo_debug "[home-spoofing] System change, will compile 'preload.so'."
		rm "$DIR/preload.so"
	fi
fi

echo "$SYSTEM_HASH" > "$SYSTEM_HASH_FILE"

if [ ! -f "$DIR/preload.so" ]; then
	echo_debug "[home-spoofing] Compiling 'preload.so'..."
	gcc -Wall -shared -fPIC "$DIR/preload.c" -ldl -o "$DIR/preload.so" || exit 1
fi

echo_debug "[home-spoofing] HOME=$NEW_HOME"

cd "$NEW_HOME"

env \
HOME="$NEW_HOME" \
HOME_IS_SPOOFED="$HOME" \
LD_PRELOAD="$DIR/preload.so" \
"$@"
