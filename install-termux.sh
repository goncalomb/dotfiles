#!/bin/bash

set -euo pipefail
cd -- "$(dirname -- "$0")"

[[ "${PREFIX:-}" != *"/com.termux/"* ]] && echo "not a termux environment" && exit 1

mkdir -p tmp/termux-apks
cd tmp/termux-apks

fdroid_apk_get_version() {
    python3 <<EOF
import urllib.request, json
with urllib.request.urlopen("https://f-droid.org/api/v1/packages/$1") as fp:
    print(json.load(fp)['suggestedVersionCode'])
EOF
}

fdroid_apk_download() {
    curl -#ROL "https://f-droid.org/repo/$1"
}

do_apk() {
    VERSION=$(fdroid_apk_get_version "$1")
    APK_FILE="$1_$VERSION.apk"
    echo "$APK_FILE"
    if [ ! -f "$APK_FILE" ]; then
        fdroid_apk_download "$APK_FILE"
    fi
    xdg-open "$APK_FILE"
    read -r -p "install the apk now, [ENTER] to continue"
}

# XXX: opinionated, i don't need other packages
do_apk com.termux.widget
do_apk com.termux.api
do_apk com.termux
