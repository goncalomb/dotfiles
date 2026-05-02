# dotfiles

My dotfiles and scripts.

The install procedure is for bash, usage with other shells is untested, but if you are here just for the scripts, they are mostly portable and many are not even shell scripts.

## Install

### Main install script (`install.sh`)

* On **Debian**-based distributions (I use [Mint](https://linuxmint.com/)), just install normally.
* On **Android** ([Termux](https://termux.com/) environment), just install normally.
* On **macOS**, the default shell is zsh (zsh support is untested, the install won't update .zshrc). Personally, I just use bash even on macOS (see [install-brew-bash.sh](install-brew-bash.sh)). Using bash, just install normally.
* On **Windows**, it was made to work with Git Bash from [Git for Windows](https://git-scm.com/download/win) which uses MSYS2/MinGW, but current support is untested (personally I haven't installed it on Windows in a long time).

Must be installed on your HOME directory or any directory below!

```bash
cd ~
git clone https://github.com/goncalomb/dotfiles.git
./dotfiles/install.sh
```

The install procedure is quite tame and does not make big changes to your system:

* it appends to `~/.bashrc` to source [bashrc](bashrc), for PS1, PATHs (for [bin](bin) and others), aliases and other configurations
* it changes the git user config `~/.gitconfig` to add `include.path` ([gitconfig](gitconfig)) and `core.excludesfile` ([gitignore](gitignore))

All other install scripts and features are optional.

### Home install script (`install-home.sh`)

The `install-home.sh` script is a more automated installer that also updates and installs system packages (you have been warned).

* it runs `apt`/`pkg` update / upgrade / auto-remove;
* installs `git` and `python3` on Linux/Termux;
* installs [Homebrew](https://brew.sh/) on macOS;
* installs the dotfiles (using `install.sh`);
* looks for a `install-home.toml` config file for further setup (see below);

It can be run independently, e.g., directly from terminal with `curl`:

```bash
curl -fsSL https://raw.githubusercontent.com/goncalomb/dotfiles/HEAD/install-home.sh | bash
```

A local `install-home.toml` can be used to further customization depending on the system. Example:

```toml
# every config table [configs.<name>] has the same fields (all optional)
# a config is only selected if the `when` condition matches the current system,
# or is set to `true`, possible keys for when:
# - platform: current platform (Linux, Termux or Darwin)
# - user: current username
# a config can extend other configs, merging their values

[configs.base] # this config is not enabled by default (missing `when`)
install_asdf = false                     # run `install-asdf.sh` from dotfiles
install_gists = false                    # run `install-gists.sh` from dotfiles
apt_packages = ["curl", "wget"]          # apt packages to install
brew_formulae = ["git", "python3"]       # homebrew formulae to install
brew_casks = ["visual-studio-code"]      # homebrew casks to install
pipx_packages = ["magic-wormhole"]       # pipx packages to install
asdf_plugins = ["nodejs"]                # asdf plugins to add
vscode_settings = "settings.json"        # file to replace vscode user settings
vscode_extensions = ["ms-python.python"] # vscode extensions to install
bashrc_extras = ["bashrc/custom"]        # files to be appended to ~/.bashrc
exec_extras = ["exec/custom.sh"]         # files to be executed (last step)

[configs.base.git_config] # global git config for base
"user.name" = "Your Name"
"user.email" = "email@example.com"

[configs.linux]
extends = ["base"]            # extends base config (merge)
when = { platform = "Linux" } # enabled only when platform is Linux
apt_packages = ["vlc"]        # e.g. add more apt packages

[configs.myuser]
extends = ["base"]         # extends base config (merge)
when = { user = "myuser" } # enabled only when the current user is "myuser"
brew_casks = ["spotify"]   # e.g. add more brew casks

[configs.always]
when = true
exec_extras = ["pwd"] # this will always be executed
```

> This may look like a convoluted way to setup a system, but this current version of `install-home.sh` is the final combination of various other setup scripts that I had before. At some point in the future I may replace this with Ansible or pyinfra. But this works for me right now.
>
> I keep my own `install-home.toml` configuration and some other scripts outside this repo, then I just run `install-home.sh` to keep the system up-to-date.

## Contents

* stable: in active use and tested
* bespoke: made for a specific use case, may not be useful to others
* \[**!**\] caution: use with caution, may do changes to your system, or has some complex behavior
* \[**?**\] unknown: unknown status, not tested recently, may be broken, experimental
* \[**X**\] disabled: old/deprecated, not tested recently, disabled by default

### Install Scripts

Main scripts that install the dotfiles:

* [install.sh](install.sh): main install script (see above, changes `~/.bashrc` and `~/.gitconfig`)
* [install-home.sh](install-home.sh): \[**!**\] automated installation, updates and installs system packages, installs dotfiles (see above)

Extra scripts that install to a `tmp/` directory inside the dotfiles:

* [install-asdf.sh](install-asdf.sh): install asdf locally
* [install-gists.sh](install-gists.sh): installs a small subset of [my gists](https://gist.github.com/goncalomb)
* [install-profile.sh](install-profile.sh): installs some extra environment files and PATHs

Other scripts:

* [install-brew-bash.sh](install-brew-bash.sh): \[**!**\] for macOS, installs bash from homebrew to replace the outdated version bundled with xcode, set it as the current user's SHELL
* [install-termux.sh](install-termux.sh): \[**!**\] helps download and install Termux APKs on Termux

### Bash

* [bashrc](bashrc): custom PS1 with git branch, PATHs, aliases, functions and other configurations
* [bashrc_termux](bashrc_termux): some aliases and functions for Termux
* [bashrc_ssh](bashrc_ssh): \[**?**\] old wrappers for ssh-agent
* [bashrc_pass](bashrc_pass): \[**X**\] old attempt at creating a password manager (disabled)

### Git

* [gitconfig](gitconfig): a small collection of git aliases
* [gitignore](gitignore): some git ignores

### Other Stuff

* [container-recipes](container-recipes): \[**?**\] specialized Docker container images, a poof of concept meant to provide a quick way to access some tools and programs without installing them on the host (managed using the [`bin/recipes`](bin/recipes) script)
* [systemd](systemd): \[**?**\] a recent attempt at hosting some personal systemd services using Ansible (you probably don't want them)
* [home-spoofing](home-spoofing): \[**X**\] old feature to provide a portable HOME directory

### Scripts (`bin/`)

These are not documented extensively, so I recommend that you read them before running. Some may do changes to your system (e.g., installing packages).

They are mostly GNU/Linux-centric but some may work on other systems (good compatibility with macOS). They are available on PATH after installing the dotfiles.

> Some of these scripts are quite old and may not work as expected, I'm working to update them as needed. Focusing on Linux, Termux and macOS support when possible. --goncalomb

Scripts | Description | Tags | Updated
------- | ----------- | ---- | -------
[a-clear](bin/a-clear) | \[**!**\] Clear Ansible cache (roles and collections). | stable, caution | 2025
[a-playbook](bin/a-playbook) | Run Ansible playbooks (`playbook.yaml` + `playbook-*.yaml`) with optional `inventory.yaml`, after installing `requirements.yaml`. | stable | 2026
[android-bak](bin/android-bak) | \[**!**\] Connect to Android (I use Termux and sshd) and backup some files. | bespoke, caution | 2022
[android-ssh](bin/android-ssh) | Connect to Android (using bcast-ip). | bespoke | 2018
[bak-disk](bin/bak-disk) | \[**!**\] Dump disk metadata and contents. | bespoke, caution | 2021
[bashrc-zone](bin/bashrc-zone) | Manage bashrc zones. | stable | 2021
[bcast-ip](bin/bcast-ip) | A simple IPv4 broadcaster. | bespoke | 2018
[browser-incognito](bin/browser-incognito) | \[**?**\] Open an independent browser window in incognito mode (Google Chrome). | unknown | 2018
[browser-socks](bin/browser-socks) | \[**?**\] Create a SOCKS proxy with a remote server and start an incognito Google Chrome instance on that proxy. | unknown | 2018
[composer](bin/composer) | \[**?**\] Run PHP composer (with auto-install). | unknown | 2017
[cryptimg](bin/cryptimg) | \[**!**\] Create/Manage/Mount LUKS encrypted images, for storing files securely. | bespoke, caution | 2022
[dl-single](bin/dl-single) | Downloads a single file from a URL (with metadata). | bespoke | 2022
[drive-serial](bin/drive-serial) | \[**?**\] Find the serial number of the physical drive. | unknown | 2017
[estore](bin/estore) | \[**?**\] Encrypted data storage (to store passwords and other data). | unknown | 2022
[gh-clone](bin/gh-clone) | \[**?**\] Clone from GitHub with `gh-clone user/repo`. | unknown | 2017
[gh-set-user](bin/gh-set-user) | \[**?**\] Sets your git name and email based on your GitHub profile. | unknown | 2018
[git-ai](bin/git-ai) | Git wrapper that adds AI suffix to the author name and email. Usage: `git ai commit ...`. | stable | 2026
[git-mtime](bin/git-mtime) | \[**?**\] Set the modified date of the files on a git repository to the last commit date that changed the files. | unknown | 2017
[git-sync](bin/git-sync) | Sync all branches and tags on all remotes (fetch + ff-only merge + push). | stable | 2026
[install-applications](bin/install-applications) | \[**!**\]\[**?**\] A utility to install some applications. | bespoke, unknown, caution | 2018
[install-extra-packages](bin/install-extra-packages) | \[**!**\]\[**?**\] Installs extra packages using apt-get from external repositories. | bespoke, unknown, caution | 2023
[install-packages](bin/install-packages) | \[**!**\]\[**?**\] A utility to install some basic packages. | bespoke, unknown, caution | 2018
[irc](bin/irc) | \[**?**\] Manages Weechat (IRC client) sessions using screen. | unknown | 2021
[logdata](bin/logdata) | A script to log events and notes throughout the day. | bespoke | 2021
[lspath](bin/lspath) | Lists the directories in PATH. | stable | 2026
[mailop](bin/mailop) | \[**?**\] Organize emails on imap mailboxes. | unknown | 2018
[mywg](bin/mywg) | \[**?**\] Configures WireGuard from a well-known configuration file. | unknown | 2023
[new-script](bin/new-script) | Creates a new bash script (using a template). | stable | 2025
[phpdoc](bin/phpdoc) | \[**?**\] Run phpDocumentor (with auto-install). | unknown | 2018
[recipes](bin/recipes) | \[**?**\] Run container recipes (see `./container-recipes`), try `recipes rs-osrs`. | bespoke, unknown | 2019
[sftp-upload](bin/sftp-upload) | \[**?**\] A hacked together SFTP uploader script (probably not worth using). | unknown | 2017
[photo-tools](bin_termux/photo-tools) | \[**!**\]\[**?**\] For Termux, cleanup photo files (JPEG and RAW). | bespoke, unknown, caution | 2023

## License

dotfiles is released under the terms of the MIT License. See [LICENSE.txt](LICENSE.txt) for details.
