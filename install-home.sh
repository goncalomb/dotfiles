#!/usr/bin/env bash

# /// dotfiles
# description = "automated installation, updates and installs system packages, installs dotfiles (see above)"
# author = "goncalomb"
# tags = ["caution"]
# ///

set -euo pipefail
DIR=$(pwd -P)
cd -- "$(dirname -- "$0")"

echo70() {
    # old bash versions (i.e. macOS) don't support \e
    echo -e "\033[7m$@\033[0m"
}

confirm() {
	read -r -p "${1:-Are you sure} (y/n)? " YESNO
	[[ "$YESNO" =~ ^[yY] ]]
}

APT_CMD=
APT_BASE_PACKAGES=()
export IH_PLATFORM=$(uname -s)
export IH_CONFIG_FILE="$DIR/install-home.toml"
export IH_DOTFILES_DIR="$HOME/dotfiles"

if [ -f "README.md" ] && [[ "$(head -n1 README.md)" == *dotfiles* ]]; then
    # looks like we are in the dotfiles repo, use it
    IH_DOTFILES_DIR="$(pwd)"
fi

if [[ "${PREFIX:-}" == *"/com.termux/"* ]]; then
    APT_CMD="pkg"
    APT_BASE_PACKAGES+=(git python)
    IH_PLATFORM="Termux"
elif [[ "$IH_PLATFORM" == "Linux" ]]; then
    APT_CMD="apt"
    APT_BASE_PACKAGES+=(git python3 python3-pip)
elif [[ "$IH_PLATFORM" == "Darwin" ]]; then
    :
else
    echo "error: unsupported platform '$IH_PLATFORM'" >&2 && exit 1
fi

echo70 "goncalomb's home install script"
echo
uname -a
echo
echo "HOME=$HOME"
echo "USER=${USER:-}" # unbound on Termux
echo "IH_PLATFORM=$IH_PLATFORM"
echo "IH_CONFIG_FILE=$IH_CONFIG_FILE"
echo "IH_DOTFILES_DIR=$IH_DOTFILES_DIR"
echo

if [ -z "${DOTFILES_GONCALOMB:-}" ]; then
    confirm "Do you understand what this script does? Continue" || exit 1
    echo
fi

if [ -n "$APT_CMD" ]; then
    echo70 update system
    $APT_CMD update -y
    $APT_CMD upgrade -y
    $APT_CMD remove -y --auto-remove
    if [ "${#APT_BASE_PACKAGES[@]}" -gt 0 ]; then
        echo70 install base packages
        $APT_CMD install -y "${APT_BASE_PACKAGES[@]}"
    fi
fi

if [ "$IH_PLATFORM" = "Darwin" ]; then
    if ! command -v brew >/dev/null; then
        echo70 install brew
        bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    # On macOS, Homebrew installs the command-line tools for Xcode,
    # so git and python are available after this point.
fi

echo70 install dotfiles
if [ ! -d "$IH_DOTFILES_DIR" ]; then
    git clone --depth=1 https://github.com/goncalomb/dotfiles.git "$IH_DOTFILES_DIR"
fi
"$IH_DOTFILES_DIR/install.sh"
"$IH_DOTFILES_DIR/install-profile.sh"

if [ ! -f "$IH_CONFIG_FILE" ]; then
    echo "config file not found, skipping personal configuration"
    exit 0
fi

if [ "$IH_DOTFILES_DIR" != "${DOTFILES_GONCALOMB:-}" ]; then
    echo "sourcing dotfiles bashrc from '$IH_DOTFILES_DIR'"
    # first time (or different dotfiles directory), source the dotfiles bashrc
    set +u # TODO: fix "unbound variable" errors
    . "$IH_DOTFILES_DIR/bashrc"
    set -u
fi

cd "$DIR"

echo70 load configuration
eval "$(python3 <<'EOF'
import os
import shlex
import sys
import tomllib

home = os.getenv('HOME')
user = os.getenv('USER')
platform = os.getenv('IH_PLATFORM')
config_file = os.getenv('IH_CONFIG_FILE')
dotfiles_dir = os.getenv('IH_DOTFILES_DIR')

config_conditions = {
    'user': user,
    'platform': platform,
}


def bash_echo(message):
    print(f"echo {shlex.quote(message)}")


def bash_value(name, value):
    if isinstance(value, list):
        print(f"declare -a {name}=({' '.join(shlex.quote(item) for item in value)})")
        return
    if isinstance(value, dict):
        print(f"declare -A {name}=({' '.join(f'[{shlex.quote(k)}]={shlex.quote(v)}' for k, v in value.items())})")
        return
    if isinstance(value, bool):
        value = '1' if value else ''
    print(f"declare {name}={shlex.quote(value)}")


if __name__ == '__main__':
    with open(config_file, 'rb') as fp:
        cfg = tomllib.load(fp)

    all_configs = []

    def config_check_when(config, extends=False):
        if 'when' in config:
            when = config['when']
            if when is True:
                return True
            for k, v in when.items():
                if k not in config_conditions:
                    print(f"Unknown condition: {k}", file=sys.stderr)
                    return False
                if config_conditions[k] != v:
                    return False
            return True
        return extends

    def config_process(name, extends=False):
        config = cfg['configs'][name]
        if config_check_when(config, extends):
            all_configs.append(name)
            if 'extends' in config:
                for parent in config['extends']:
                    config_process(parent, extends=True)

    def config_merge(configs):
        merged = {
            'install_asdf': False,
            'install_gists': False,
            'apt_packages': [],
            'brew_formulae': [],
            'brew_casks': [],
            'pipx_packages': [],
            'git_config': {},
            'asdf_plugins': [],
            'vscode_settings': '',
            'vscode_extensions': [],
            'bashrc_extras': [],
            'exec_extras': [],
        }
        for name in reversed(configs):
            config = cfg['configs'][name]
            for key in merged.keys():
                if key in config:
                    if isinstance(merged[key], bool):
                        merged[key] |= config[key]
                    elif isinstance(merged[key], list):
                        merged[key].extend(config[key])
                    elif isinstance(merged[key], dict):
                        merged[key].update(config[key])
                    else:
                        merged[key] = config[key]
        return merged

    for name in cfg['configs'].keys():
        config_process(name)

    merged_config = config_merge(all_configs)
    bash_echo(f"Using configs: {', '.join(all_configs)}")
    for key, value in merged_config.items():
        bash_value(key.upper(), value)
EOF
)"

if [ -n "$INSTALL_ASDF" ]; then
    echo70 install asdf
    "$IH_DOTFILES_DIR/install-asdf.sh"
fi

if [ -n "$INSTALL_GISTS" ]; then
    echo70 install gists
    "$IH_DOTFILES_DIR/install-gists.sh"
fi

if [ ${#APT_PACKAGES[@]} -gt 0 ] && [ -n "$APT_CMD" ]; then
    echo70 install apt packages
    $APT_CMD install -y "${APT_PACKAGES[@]}"
fi

if command -v brew >/dev/null && [ ${#BREW_FORMULAE[@]} -gt 0 ]; then
    echo70 install brew formulae
    brew install --formulae "${BREW_FORMULAE[@]}"
fi

if command -v brew >/dev/null && [ ${#BREW_CASKS[@]} -gt 0 ]; then
    echo70 install brew casks
    brew install --casks "${BREW_CASKS[@]}"
fi

if command -v pipx >/dev/null && [ ${#PIPX_PACKAGES[@]} -gt 0 ]; then
    echo70 install pipx packages
    pipx install "${PIPX_PACKAGES[@]}"
    pipx upgrade-all
fi

if command -v git >/dev/null && [ ${#GIT_CONFIG[@]} -gt 0 ]; then
    echo70 setup git config
    for KEY in "${!GIT_CONFIG[@]}"; do
        echo "$KEY = ${GIT_CONFIG[$KEY]}"
        git config --global "$KEY" "${GIT_CONFIG[$KEY]}"
    done
    echo "git user: $(git config --global --get user.name) <$(git config --global --get user.email)>"
fi

if command -v asdf >/dev/null && [ ${#ASDF_PLUGINS[@]} -gt 0 ]; then
    echo70 setup asdf plugins
    for PLG in "${ASDF_PLUGINS[@]}"; do
        asdf plugin add "$PLG"
    done
fi

if command -v code >/dev/null; then
    echo70 setup vscode
    VSC_SETTINGS="$HOME/.config/Code/User/settings.json"
    if [ "$IH_PLATFORM" == "Darwin" ]; then
        VSC_SETTINGS="$HOME/Library/Application Support/Code/User/settings.json"
    fi
    VSC_EXTENSIONS=$(code --list-extensions)
    if [ -f "$VSCODE_SETTINGS" ]; then
        echo "copy settings"
        cp "$VSCODE_SETTINGS" "$VSC_SETTINGS"
    fi
    VSC_ARGS=()
    for EXT in "${VSCODE_EXTENSIONS[@]}"; do
        for E in $VSC_EXTENSIONS; do
            if [ "$EXT" == "$E" ]; then
                EXT=
                break
            fi
        done
        [ -z "$EXT" ] || VSC_ARGS+=("--install-extension" "$EXT")
    done
    if [ ${#VSC_ARGS[@]} -gt 0 ]; then
        code "${VSC_ARGS[@]}"
    fi
fi

if [ ${#BASHRC_EXTRAS[@]} -gt 0 ]; then
    echo70 bashrc extras
    for EXTRA in "${BASHRC_EXTRAS[@]}"; do
        echo "$EXTRA"
        KEY="install-home-$(basename "$EXTRA")"
        bashrc-zone remove "$KEY"
        cat "$EXTRA" | bashrc-zone add "$KEY"
    done
fi

if [ ${#EXEC_EXTRAS[@]} -gt 0 ]; then
    echo70 exec extras
    for EXTRA in "${EXEC_EXTRAS[@]}"; do
        echo "$EXTRA"
        "$EXTRA"
    done
fi

echo70 all done
echo "reset the terminal to reload your environment"
echo "re-run to update the tools/programs"
