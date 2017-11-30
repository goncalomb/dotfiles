# dotfiles

My dotfiles and scripts for your favorite Linux distro (I use [Mint](https://linuxmint.com/download.php)) and [Termux](https://termux.com/) on Android.

## Install

Must be installed on you $HOME directory or below! **BE AWARE!** It will prompt you to replace your .bashrc and .gitconfig files! If you don't want to replace your .bashrc just add `source "$HOME/dotfiles/bashrc"` to it. If you just want to use the scripts add `bin/` to your $PATH.

    cd ~
    git clone https://github.com/goncalomb/dotfiles.git
    ./dotfiles/install.sh

## Contents

### Bash

A custom PS1 with git branch, some aliases and functions, see [bashrc](bashrc).

### Git

A small collection of git aliases [gitconfig](gitconfig).

### Home Spoofing

**Advanced, requires gcc, needs more documentation?**

With home spoofing you can carry you home directory with you!

Clone this repository to a external drive, then run `YOUR_DRIVE_LOCATION/dotfiles/home-spoofing/spoof.sh bash` this will open a new bash instance with the $HOME path set to the external drive (see [spoof.sh](home-spoofing/spoof.sh)). It also compiles a and preloads a shared library (see [preload.c](home-spoofing/preload.c)) using LD_PRELOAD, that intercepts some standard C functions to better spoof the HOME directory.

All programs started from that shell will see the spoofed HOME directory and use it to store their config files, making your HOME directory portable.

It's not required to start a shell to spoof the HOME for a specific program, just run `YOUR_DRIVE_LOCATION/dotfiles/home-spoofing/spoof.sh your_program some_argument`.

If you use GNOME, it's useful to create a `open-terminal.desktop` file on the external drive to quickly open a spoofed shell or other programs, example:

    [Desktop Entry]
    Terminal=true
    Name=Terminal
    Exec=bash -c "$(dirname -- "%k")/dotfiles/home-spoofing/spoof.sh bash"
    Type=Application
    Icon=gnome-panel-launcher

### Scripts

Scripts | Description
--------|------------
[android-bak](bin/android-bak) | Connect to a Android phone (I use Termux and sshd) and backup some files.
[composer](bin/composer) | Run PHP composer (with auto-install).
[drive-serial](bin/drive-serial) | Find the serial number of the physical drive.
[estore](bin/estore) ([src](bin/src/estore.py)) | Encrypted data storage (to store passwords and other data).
[git-mtime](bin/git-mtime) | Set the modified date of the files on a git repository to the last commit date that changed the files.
[sftp-upload](bin/sftp-upload) ([src](bin/src/sftp-upload/sftp-upload.php)) | A hacked together SFTP uploader script (probably not worth using).
[socks-for-chrome](bin/socks-for-chrome) | Create a SOCKS proxy with a remote server and start a incognito Google Chrome instance on that proxy.

## License

dotfiles is released under the terms of the MIT License. See [LICENSE.txt](LICENSE.txt) for details.