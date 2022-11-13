#!/bin/bash

set -euo pipefail
cd -- "$(dirname -- "$0")"

[ ! -d "/etc/systemd/system" ] && echo "no '/etc/systemd/system'" && exit 1
[ ! -d "/usr/local/sbin" ] && echo "no '/usr/local/sbin'" && exit 1

sudo_hard_cp_file() {
    echo "$1 > $2"
    sudo rm -f "$2"
    sudo cp "$1" "$2"
    [ -z "${3:-}" ] || sudo chmod "$3" "$2"
}

sudo -v
cd systemd/services

find . -mindepth 1 -maxdepth 1 -name "*.service" -printf "%f\n" | while IFS= read -r F_SVC; do
    echo "$F_SVC"
    # stop existing service
    if [ -f "/etc/systemd/system/$F_SVC" ]; then
        sudo systemctl disable "$F_SVC"
        sudo systemctl stop "$F_SVC"
    fi
    # install service files
    sudo_hard_cp_file "$F_SVC" "/etc/systemd/system/$F_SVC"
    F_BIN=${F_SVC%.service}
    if [ -f "$F_BIN" ]; then
        sudo_hard_cp_file "$F_BIN" "/usr/local/sbin/$F_BIN" "u+x"
    fi
    # restart service
    sudo systemctl enable "$F_SVC"
    sudo systemctl start "$F_SVC"
    systemctl --no-pager --full status "$F_SVC"
done
