#!/bin/bash

set -e
cd -- "$(dirname -- "$0")"

! command -v bashrc-zone > /dev/null && echo "'bashrc-zone' not found, are the dotfiles installed?" && exit 1

# https://asdf-vm.com/#/core-manage-asdf

mkdir -p tmp
cd tmp

if [ -d asdf ]; then
    git -C asdf checkout master
    git -C asdf pull --ff-only
else
    git clone https://github.com/asdf-vm/asdf.git
fi

git -C asdf checkout "$(git -C asdf describe --abbrev=0 --tags)"
