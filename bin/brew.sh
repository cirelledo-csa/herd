#!/bin/bash
set -x
echo make sure 'eval $(~/.linuxbrew/bin/brew shellenv)'  is in your ~/.bashrc
if ! command -v brew &> /dev/null
then
	echo "brew not found, downloading and installing"
	mkdir -p ~/.linuxbrew/bin
	git clone https://github.com/Homebrew/brew ~/.linuxbrew/Homebrew
	ln -s ../Homebrew/bin/brew ~/.linuxbrew/bin
else
	echo "brew found, nothing doing"
fi


if [[ "$OSTYPE" == "linux"* ]]
then
    brewfile="Brewfile-linux"
elif [[ "$OSTYPE" == "darwin"* ]]
then
    brewfile="Brewfile-macosx"
else
  "can't find os, exiting";exit
fi
eval "$(~/.linuxbrew/bin/brew shellenv)"
brew bundle --file="$brewfile"
brew link --overwrite  awscli
