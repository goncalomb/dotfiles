# dotfiles

My dotfiles and scripts for your favorite Linux environment, I use [Mint](https://linuxmint.com/) and [Termux](https://termux.com/) on Android.

The install procedure is for bash, usage with other shells is untested, but the scripts should be mostly portable and many are not even shell scripts.

It should work on macOS.

## Install

Must be installed on your $HOME directory or any directory below!

    cd ~
    git clone https://github.com/goncalomb/dotfiles.git
    ./dotfiles/install.sh

The install is quite tame and does not make big changes to your system.

* it appends to '~/.bashrc' to source 'bashrc' from this repo
* it changes the git global config '~/.gitconfig' to add 'include include.path' and 'core.excludesfile'

Please do review the 'install.sh' script if you want. Also, you can just add `source "$HOME/dotfiles/bashrc"` to your init file if you want more control.

## Contents

### Bash

A custom PS1 with git branch, some aliases and functions, see [bashrc](bashrc). When installed on Android with Termux, some extra bash functions are available, see [bashrc_termux](bashrc_termux).

### Git

A small collection of git aliases [gitconfig](gitconfig).

### Home Spoofing

**Advanced, requires gcc, needs more documentation?**

With home spoofing you can carry you home directory with you!

Clone this repository to a external drive, then run `YOUR_DRIVE_LOCATION/dotfiles/home-spoofing/spoof.sh bash` this will open a new bash instance with the $HOME path set to the external drive (see [spoof.sh](home-spoofing/spoof.sh)). It also compiles and preloads a shared library (see [preload.c](home-spoofing/preload.c)) using LD_PRELOAD, that intercepts some standard C functions to better spoof the HOME directory.

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

These are not documented extensively, so I recommend that you read them before running. Nevertheless they don't make changes to your system, with the exception of 'install-*' and 'bashrc-zone' probably..

Scripts | Description
--------|------------
[android-bak](bin/android-bak) | Connect to Android (I use Termux and sshd) and backup some files.
[android-ssh](bin/android-ssh) | Connect to Android (using bcast-ip).
[bak-disk](bin/bak-disk) | Dump disk metadata and contents.
[bashrc-zone](bin/bashrc-zone) | Manage bashrc zones.
[bcast-ip](bin/bcast-ip) | A simple IPv4 broadcaster.
[browser-incognito](bin/browser-incognito) | Open an independent browser window in incognito mode (Google Chrome).
[browser-socks](bin/browser-socks) | Create a SOCKS proxy with a remote server and start an incognito Google Chrome instance on that proxy.
[composer](bin/composer) | Run PHP composer (with auto-install).
[cryptimg](bin/cryptimg) | Create/Manage/Mount LUKS encrypted images, for storing files securely.
[drive-serial](bin/drive-serial) | Find the serial number of the physical drive.
[estore](bin/estore) ([src](bin/src/estore.py)) | Encrypted data storage (to store passwords and other data).
[gh-clone](bin/gh-clone) | Clone from GitHub with `gh-clone user/repo`.
[gh-set-user](bin/gh-set-user) | Sets your git name and email based on your GitHub profile.
[git-mtime](bin/git-mtime) | Set the modified date of the files on a git repository to the last commit date that changed the files.
[install-applications](bin/install-applications) | A utility to install some applications.
[install-packages](bin/install-packages) | A utility to install some basic packages.
[install-extra-packages](bin/install-extra-packages) | Installs extra packages using apt-get from external repositories.
[logdata](bin/logdata) | A script to log events and notes throughout the day.
[mailop](bin/mailop) | Organize emails on imap mailboxes.
[phpdoc](bin/phpdoc) | Run phpDocumentor (with auto-install).
[recipes](bin/recipes) | Run container recipes (see `./container-recipes`), try `recipes rs-osrs`.
[sftp-upload](bin/sftp-upload) ([src](bin/src/sftp-upload/sftp-upload.php)) | A hacked together SFTP uploader script (probably not worth using).

## License

dotfiles is released under the terms of the MIT License. See [LICENSE.txt](LICENSE.txt) for details.
