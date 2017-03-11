function confirm {
	read -r -p "${1:-Are you sure} (y/n)? " YESNO
	if [[ "$YESNO" =~ ^[yY] ]]; then true; else false; fi
}

# remote scripts from my gists
alias img2ico="curl -s \"https://gist.githubusercontent.com/goncalomb/6d879df103fda9b63feb/raw/img2ico.php\" | php -- $@"
alias git-problems="curl -s \"https://gist.githubusercontent.com/goncalomb/13f28e459fe4dd656e8b43f92c826140/raw/git-problems\" | bash"

# remote speed test script
alias speed="curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python"

# misc
alias clock="while true; do echo -n \`date\`; sleep 0.1; echo -ne \"\r\e[K\"; done"
alias socks="echo \"Starting SOCKS tunnel on port 8100...\"; ssh -D 8100 -CnN -- $1"
