# dotfiles

My dotfiles and scripts.

The install procedure is for bash, usage with other shells is untested, but if you are here just for the scripts, they are mostly portable and many are not even shell scripts.

## Install

* On **Debian**-based distributions (I use [Mint](https://linuxmint.com/)), just install normally.
* On **Android** ([Termux](https://termux.com/) environment), just install normally.
* On **macOS**, the default shell is zsh (zsh support is untested, the install won't update .zshrc). Personally, I just use bash even on macOS (see [utils/darwin-use-brew-bash.sh](utils/darwin-use-brew-bash.sh), requires [Homebrew](https://brew.sh/)). Using bash, just install normally.
* On **Windows**, it was made to work with Git Bash from [Git for Windows](https://git-scm.com/download/win) which uses MSYS2/MinGW, but current support is untested (personally I haven't installed it on Windows in a long time).

Must be installed on your HOME directory or any directory below!

    cd ~
    git clone https://github.com/goncalomb/dotfiles.git
    ./dotfiles/install.sh

The install procedure is quite tame and does not make big changes to your system:

* it appends to '~/.bashrc' to source [bashrc](bashrc), for PS1, PATHs (for [bin](bin) and others), aliases and other configurations
* it changes the git user config '~/.gitconfig' to add 'include.path' ([gitconfig](gitconfig)) and 'core.excludesfile' ([gitignore](gitignore))

Please do review the [install.sh](install.sh) script if you want. All other install scripts and features are optional.

### Personal Note

My personal install procedure is something like this:

    # on macOS: install homebrew (don't setup shellenv, dotfiles includes shellenv setup)
    cd ~
    git clone https://github.com/goncalomb/dotfiles.git
    ./dotfiles/install.sh
    ./dotfiles/install-profile.sh
    ./dotfiles/install-asdf.sh
    ./dotfiles/install-gists.sh
    # restart the terminal
    ./dotfiles/utils/darwin-use-brew-bash.sh # on macOS
    ./dotfiles/install-termux.sh # on Termux
    # restart the terminal

## Contents

* [**?**]: experimental features, with limited usefulness
* [**X**]: old/deprecated features, not tested recently, disabled by default

### Install Scripts and Utils

These scripts only do local changes that won't affect your system:

* [install.sh](install.sh): main install script (see above, changes '~/.bashrc' and '~/.gitconfig')
* [install-asdf.sh](install-asdf.sh): install asdf locally
* [install-gists.sh](install-gists.sh): installs a small subset of [my gists](https://gist.github.com/goncalomb)
* [install-profile.sh](install-profile.sh): installs some extra environment files and PATHs

These scripts may do changes to your system:

* [**?**] [install-systemd.sh](install-systemd.sh): installs systemd services (you probably don't want it)
* [install-termux.sh](install-termux.sh): helps download and install Termux APKs on Termux
* [utils/darwin-use-brew-bash.sh](utils/darwin-use-brew-bash.sh): for macOS, installs bash from homebrew to replace the outdated version bundled with xcode, set it as the current user's SHELL

### Bash

* [bashrc](bashrc): custom PS1 with git branch, PATHs, aliases, functions and other configurations
* [bashrc_termux](bashrc_termux): some aliases and functions for Termux
* [**?**] [bashrc_ssh](bashrc_ssh): old wrappers for ssh-agent
* [**X**] [bashrc_pass](bashrc_pass): old attempt at creating a password manager (disabled)

### Git

* [gitconfig](gitconfig): a small collection of git aliases
* [gitignore](gitignore): some git ignores

### Other Stuff

* [**?**] [container-recipes](container-recipes): specialized Docker container images, a poof of concept meant to provide a quick way to access some tools and programs without installing them on the host (managed using the [`bin/recipes`](bin/recipes) script)
* [**?**] [systemd](systemd): a recent attempt at hosting some systemd services (see [install-systemd.sh](install-systemd.sh))
* [**X**] [home-spoofing](home-spoofing): old feature to provide a portable HOME directory

### Scripts

These are not documented extensively, so I recommend that you read them before running. Nevertheless, they don't make changes to your system, except for 'install-*' and 'bashrc-zone' probably...

They are mostly GNU/Linux-centric but some may work on other systems. They are available on PATH after installing the dotfiles.

The list is not exhaustive (see [bin](bin)).

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
