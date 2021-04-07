#!/bin/bash
set -x
echo make sure 'eval $(~/.linuxbrew/bin/brew shellenv)'  is in your ~/.bashrc
if ! command -v brew &> /dev/null
then
	echo "brew not found, downloading and installing"
	git clone https://github.com/Homebrew/brew ~/.linuxbrew/Homebrew
	mkdir ~/.linuxbrew/bin
	ln -s ../Homebrew/bin/brew ~/.linuxbrew/bin
	exit
else
	echo "brew found, nothing doing"
fi
brew bundle --file=Brewfile
