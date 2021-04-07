#!/bin/bash
echo "Hello, let's setup git"
echo "your current ~/.gitconfig file will be modified"
date=$(date +"%Y-%m-%d-%H:%M:%S")
gitback=~/.gitconfig-$date
echo "the original ~/.gitconfig file will be moved to $gitback"
echo "Let's start with git."
cp -a ~/.gitconfig "$gitback"
name=$(git config user.name)
if [ -z "$name" ]
then
	echo "git name is empty"
	echo "Enter your name eg John Doe"
	read varname
	git config --global user.name "$varname"  
	echo "your git name is" `git config  --get user.name`
else
	echo "git name is NOT empty. nothing doing."
fi
email=$(git config user.email)
if [ -z "$email" ]
then
	echo "git email is empty"
	echo "Enter your email  eg john.doe@faceless.corp"
	read varname
	git config --global user.email "$varname"  
	echo "your git email is" `git config  --get user.email`
else
	echo "git email is NOT empty. nothing doing."
fi
git config --global credential.helper  '!aws codecommit credential-helper $@'
git config --global credential.UseHttpPath  'true'
git config --global core.editor  'vim'
FILE=~/.ssh/ucopacme
if [ -f $FILE ]; then
	echo "File $FILE exists. doing nothing"
else
	echo "File $FILE does not exist. creating ssh key for github"
	ssh-keygen -f $FILE
fi
FILE=~/.ssh/ucopacme.pub
if [ -f $FILE ]
then
	echo "your public ssh key is:"
	echo 
	cat $FILE
	echo
	echo "configure ssh to use this key for github acess by adding a section to ~/.ssh/config file"
	echo
	echo "Host github.com"
	echo "  IdentityFile ~/.ssh/ucopacme"
	echo
	echo "copy your public ssh key to github by going to https://github.com/settings/ssh/new"
else
	echo "File $FILE does not exist. You should create an ssh key for github access"
fi
