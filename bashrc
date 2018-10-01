DIR=$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")

shopt -s expand_aliases
export HISTFILESIZE=100000
export HISTSIZE=1000

function confirm {
	read -r -p "${1:-Are you sure} (y/n)? " YESNO
	if [[ "$YESNO" =~ ^[yY] ]]; then true; else false; fi
}

export PATH="$PATH:$DIR/bin"
export PATH="$PATH:$HOME/.config/composer/vendor/bin"

# prompt variables
HIS=""
if [ ! -z "$HOME_IS_SPOOFED" ]; then
	HIS="\[\e[01;35m\]H "
fi
_PS1_EXIT=
_PS1_EXIT_0=
_ps1_root_color() {
	[ $EUID == 0 ] && echo -en "\x01\e[1;31m\x02"
}
_ps1_gitbranch() {
	BRANCH=$(git rev-parse --abbrev-ref HEAD 2> /dev/null)
	[[ -n "$BRANCH" ]] && echo -e "\x01\e[01;33m\x02$BRANCH "
}
PS1="\[\e[01;32m\]\$(_ps1_root_color)\u@\h\[\e[01;34m\] \w $HIS\$(_ps1_gitbranch)\n" # first line
PS1="\${_PS1_EXIT[\#]-\${_PS1_EXIT_0[\$?]-\e[33m(exit status \$?)\e[0m\n}$PS1}\${_PS1_EXIT[\#]=}" # exit status (https://stackoverflow.com/a/27473009)
PS1="$PS1\[\e[01;32m\]\$(_ps1_root_color)>:\[\e[00m\] " # second line
PS1="\[\e]0;\u@\h: \w\a\]$PS1" # window title
PS2="> "
PS3=""
PS4="+ "

# remote scripts from my gists
alias img2ico="curl -s \"https://gist.githubusercontent.com/goncalomb/6d879df103fda9b63feb/raw/img2ico.php\" | php --"
alias git-problems="curl -s \"https://gist.githubusercontent.com/goncalomb/13f28e459fe4dd656e8b43f92c826140/raw/git-problems\" | bash -s -"

# remote speed test script
alias speed="curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python -"

# lightdm
if command -v lightdm > /dev/null; then
	alias xon="sudo service lightdm start"
	alias xoff="sudo service lightdm stop"
fi

# misc
alias ~="cd ~"
alias ..="cd .."
alias -- -="cd -"
alias l="ls -l"
alias la="ls -la"
alias bashrc=". $HOME/.bashrc"
alias syslog="tail -n 100 -f /var/log/syslog"
alias 80="eval \`resize | grep -v \"export\"\`; resize -s \$LINES 80 > /dev/null"
alias 160="eval \`resize | grep -v \"export\"\`; resize -s \$LINES 160 > /dev/null"
alias small="resize -s 24 80 > /dev/null"
alias big="resize -s 36 120 > /dev/null"
alias clock="while true; do echo -n \`date\`; sleep 0.1; echo -ne \"\r\e[K\"; done"
alias socks="echo \"Starting SOCKS tunnel on port 8100...\"; ssh -D 8100 -CnN --"
alias clip="xclip -sel clip"
alias clip-key="xclip -sel clip < ~/.ssh/id_rsa.pub"
alias t="date -Is; date +%s.%N | tee >(tr -d \" \n\" | clip)"
alias random-64k="dd if=/dev/urandom count=128 bs=512 2> /dev/null"
alias random-md5="random-64k | md5sum | cut -d' ' -f1"
alias random-sha1="random-64k | sha1sum | cut -d' ' -f1"
alias random-sha256="random-64k | sha256sum | cut -d' ' -f1"
alias random-sha512="random-64k | sha512sum | cut -d' ' -f1"
# https://askubuntu.com/a/145017
alias mylocalip="LANG=c ifconfig | grep -B1 \"inet addr\" | awk '{ if ( \$1 == \"inet\" ) { print \$2 } else if ( \$2 == \"Link\" ) { printf \"%s:\" ,\$1 } }' | awk -F: '{ print \$1 \": \" \$3 }'"
# https://major.io/icanhazip-com-faq/
alias myip="curl -s https://icanhazip.com/"
alias myip4="curl -s -4 https://icanhazip.com/"
alias myhost="curl -s https://icanhazptr.com/"
alias myhost4="curl -s -4 https://icanhazptr.com/"
# https://askubuntu.com/a/184732
alias z="gnome-screensaver-command -l"
# https://askubuntu.com/a/131022
alias zz="dbus-send --system --print-reply --dest=\"org.freedesktop.UPower\" /org/freedesktop/UPower org.freedesktop.UPower.Suspend"
alias zzz="dbus-send --system --print-reply --dest=\"org.freedesktop.UPower\" /org/freedesktop/UPower org.freedesktop.UPower.Hibernate"
# https://stuff.goncalomb.com/euromillions.php
alias em="echo \"EuroMillions Results...\"; curl -s \"https://stuff.goncalomb.com/euromillions.php\" | grep -v ^# | head -n3"

function mkd() {
	mkdir -p -- "$*" && cd -- "$*"
}

function port-scan-full {
	nc -zv "$1" 1-65535 2>&1 | grep --color=never succeeded
}

function home-cleanup {
	confirm "This will remove some files from your home directory. Are you sure" || return
	confirm "DANGER! Delete the files" || return
	rm "$HOME/.bash_history"
	rm "$HOME/.python_history"
	rm "$HOME/.sqlite_history"
	rm "$HOME/.lesshst"
	rm "$HOME/.node_repl_history"
	rm -r "$HOME/.m2"
	rm -r "$HOME/.pip"
	rm -r "$HOME/.npm"
}

source "$DIR/bashrc_pass"
source "$DIR/bashrc_ssh"
if [[ "$PREFIX" == *"/com.termux/"* ]]; then
	source "$DIR/bashrc_termux"
fi
