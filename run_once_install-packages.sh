#!/bin/sh
set -e

# Detect package manager
if command -v brew >/dev/null 2>&1; then
	PM="brew"
elif command -v apt >/dev/null 2>&1; then
	PM="apt"
elif command -v paru >/dev/null 2>&1; then
	PM="paru"
else
	echo "No supported package manager found."
	exit 0 # Exit gracefully if no PM found
fi

install_pkg() {
	case "$PM" in
		brew)
			brew install "$@"
			;;
		apt)
			sudo apt update
			sudo apt install -y "$@"
			;;
		paru)
			paru -S --noconfirm "$@"
			;;
	esac
}

# Install packages
install_pkg git curl wget bob ripgrep fd nushell starship zoxide
install_pkg lazygit fastfetch atuin zellij unp carapace
