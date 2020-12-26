#!/usr/bin/env bash
# Script to link dotfiles to home dir

home="~/"

declare -a files=("vim" "vimrc" "atom")

for i in "${files[@]}"
do
	ln -s ./$i 	~/.$i 

done


