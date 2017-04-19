DIR=$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")

function confirm {
	read -r -p "${1:-Are you sure} (y/n)? " YESNO
	if [[ "$YESNO" =~ ^[yY] ]]; then true; else false; fi
}

if [[ "$PREFIX" == *"/com.termux/"* ]]; then
	export PATH="$PATH:$DIR/bin/termux"
else
	export PATH="$PATH:$DIR/bin"
fi

# prompt variables
HIS=""
if [ ! -z "$HOME_IS_SPOOFED" ]; then
	HIS="\[\e[01;35m\]H "
fi
function _ps1_gitbranch {
	BRANCH=$(git rev-parse --abbrev-ref HEAD 2> /dev/null)
	[[ -n "$BRANCH" ]] && echo -e "\x01\e[01;33m\x02$BRANCH "
}
PS1="\[\e[01;32m\]\u@\h\[\e[01;34m\] \w $HIS\$(_ps1_gitbranch)\[\e[01;32m\]>:\[\e[00m\] "
PS1="\[\e]0;\u@\h: \w\a\]$PS1" # window title
PS2="> "
PS3=""
PS4="+ "

# remote scripts from my gists
alias img2ico="curl -s \"https://gist.githubusercontent.com/goncalomb/6d879df103fda9b63feb/raw/img2ico.php\" | php -- $@"
alias git-problems="curl -s \"https://gist.githubusercontent.com/goncalomb/13f28e459fe4dd656e8b43f92c826140/raw/git-problems\" | bash"

# remote speed test script
alias speed="curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python"

# misc
alias 80="eval \`resize | grep -v \"export\"\`; resize -s \$LINES 80 > /dev/null"
alias 160="eval \`resize | grep -v \"export\"\`; resize -s \$LINES 160 > /dev/null"
alias small="resize -s 24 80 > /dev/null"
alias big="resize -s 36 120 > /dev/null"
alias clock="while true; do echo -n \`date\`; sleep 0.1; echo -ne \"\r\e[K\"; done"
alias socks="echo \"Starting SOCKS tunnel on port 8100...\"; ssh -D 8100 -CnN -- $1"
alias clip="xclip -sel clip"
alias clip-key="xclip -sel clip < ~/.ssh/id_rsa.pub"
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

source "$DIR/bashrc_ssh"
