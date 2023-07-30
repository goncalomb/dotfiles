#!/bin/bash

set -e
cd -- "$(dirname -- "$0")"

mkdir -p tmp/bin
cd tmp/bin

dl_gist() {
    NAME="${1##*/}"
    echo "${2:-$NAME}"
    # download
    curl -#ROL "https://gist.githubusercontent.com/$1"
    # fix shebang
    if [ -n "$3" ] && [ "$(head -n 1 "$NAME")" != "$3" ]; then
        {
            echo "$3"
            cat "$NAME"
        } >"$NAME.tmp"
        mv "$NAME.tmp" "$NAME"
    fi
    # set as executable
    chmod +x "$NAME"
    # fix name
    [ -z "$2" ] || mv "$NAME" "$2"
}

dl_gist "goncalomb/6d879df103fda9b63feb/raw/img2ico.php" "img2ico" "#!/bin/env php"
dl_gist "goncalomb/13f28e459fe4dd656e8b43f92c826140/raw/git-problems"
dl_gist "goncalomb/a71fd8581c330e4e2f86a3c15af1e3f7/raw/git-mtime"
