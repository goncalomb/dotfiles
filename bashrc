DIR=$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")

function confirm {
	read -r -p "${1:-Are you sure} (y/n)? " YESNO
	if [[ "$YESNO" =~ ^[yY] ]]; then true; else false; fi
}

export PATH="$PATH:$DIR/bin"

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
alias clock="while true; do echo -n \`date\`; sleep 0.1; echo -ne \"\r\e[K\"; done"
alias socks="echo \"Starting SOCKS tunnel on port 8100...\"; ssh -D 8100 -CnN -- $1"
