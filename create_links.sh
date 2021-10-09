#!/usr/bin/env bash
# Script to link dotfiles to home dir

home="~/"

declare -a files=("vim" "vimrc" "tmux.conf")

for i in "${files[@]}"
do
	ln -s $PWD/$i 	~/.$i 

done


