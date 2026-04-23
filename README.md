# dotfiles

My dotfiles and scripts.

The install procedure is for bash, usage with other shells is untested, but if you are here just for the scripts, they are mostly portable and many are not even shell scripts.

## Install

### Main install script (`install.sh`)

* On **Debian**-based distributions (I use [Mint](https://linuxmint.com/)), just install normally.
* On **Android** ([Termux](https://termux.com/) environment), just install normally.
* On **macOS**, the default shell is zsh (zsh support is untested, the install won't update .zshrc). Personally, I just use bash even on macOS (see [utils/darwin-use-brew-bash.sh](utils/darwin-use-brew-bash.sh), requires [Homebrew](https://brew.sh/)). Using bash, just install normally.
* On **Windows**, it was made to work with Git Bash from [Git for Windows](https://git-scm.com/download/win) which uses MSYS2/MinGW, but current support is untested (personally I haven't installed it on Windows in a long time).

Must be installed on your HOME directory or any directory below!

```bash
cd ~
git clone https://github.com/goncalomb/dotfiles.git
./dotfiles/install.sh
```

The install procedure is quite tame and does not make big changes to your system:

* it appends to '~/.bashrc' to source [bashrc](bashrc), for PS1, PATHs (for [bin](bin) and others), aliases and other configurations
* it changes the git user config '~/.gitconfig' to add 'include.path' ([gitconfig](gitconfig)) and 'core.excludesfile' ([gitignore](gitignore))

All other install scripts and features are optional.

### Home install script (`install-home.sh`)

The `install-home.sh` script is a more automated installer that also updates and installs system packages (you have been warned).

* it runs `apt`/`pkg` update / upgrade / auto-remove;
* installs `git` and `python3` on Linux/Termux;
* installs Homebrew on macOS;
* installs the dotfiles (using `install.sh`);

It can be run independently, e.g., directly from terminal with `curl`:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/goncalomb/dotfiles/HEAD/install-home.sh)"
```

### Personal Note

My personal install procedure is something like this:

```bash
# install using install-home.sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/goncalomb/dotfiles/HEAD/install-home.sh)"
# install extras
~/dotfiles/install-asdf.sh
~/dotfiles/install-gists.sh
# install other packages and applications (outside this repo)
# restart the terminal
~/dotfiles/utils/darwin-use-brew-bash.sh # on macOS
~/dotfiles/install-termux.sh # on Termux
# restart the terminal
```

_I'm currently improving this procedure, and in the future I will update `install-home.sh` to completely automate system bootstrap/updating (using a declarative configuration). --goncalomb_

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

* [install-home.sh](install-home.sh): automated installation, updates and installs system packages, installs dotfiles (see above)
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

Scripts | Description | Tags | Updated
------- | ----------- | ---- | -------
[a-clear](bin/a-clear) | Clear Ansible cache (roles and collections). | stable, caution | 2025
[a-playbook](bin/a-playbook) | Run Ansible playbooks (`playbook.yaml` + `playbook-*.yaml`) with `inventory.yaml`, also installs `requirements.yaml`. | stable | 2025
[android-bak](bin/android-bak) | - | - | -
[android-ssh](bin/android-ssh) | - | - | -
[bak-disk](bin/bak-disk) | - | - | -
[bashrc-zone](bin/bashrc-zone) | - | - | -
[bcast-ip](bin/bcast-ip) | - | - | -
[browser-incognito](bin/browser-incognito) | - | - | -
[browser-socks](bin/browser-socks) | - | - | -
[composer](bin/composer) | - | - | -
[cryptimg](bin/cryptimg) | - | - | -
[dl-single](bin/dl-single) | - | - | -
[drive-serial](bin/drive-serial) | - | - | -
[estore](bin/estore) | - | - | -
[gh-clone](bin/gh-clone) | - | - | -
[gh-set-user](bin/gh-set-user) | - | - | -
[git-ai](bin/git-ai) | Git wrapper that adds AI suffix to the author name and email. Usage: `git ai commit ...`. | stable | 2026
[git-mtime](bin/git-mtime) | - | - | -
[git-sync](bin/git-sync) | Sync all branches and tags on all remotes (fetch + ff-only merge + push). | stable | 2026
[install-applications](bin/install-applications) | - | - | -
[install-extra-packages](bin/install-extra-packages) | - | - | -
[install-packages](bin/install-packages) | - | - | -
[irc](bin/irc) | - | - | -
[logdata](bin/logdata) | - | - | -
[lspath](bin/lspath) | Lists the directories in PATH. | stable | 2026
[mailop](bin/mailop) | - | - | -
[mywg](bin/mywg) | - | - | -
[new-script](bin/new-script) | Creates a new bash script (using a template). | stable | 2025
[phpdoc](bin/phpdoc) | - | - | -
[recipes](bin/recipes) | - | - | -
[sftp-upload](bin/sftp-upload) | - | - | -

## License

dotfiles is released under the terms of the MIT License. See [LICENSE.txt](LICENSE.txt) for details.
