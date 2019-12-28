#!/usr/bin/env bash
# Script to link dotfiles to home dir

home="~/"

declare -a files=("bashrc" "bash_profile" "vim" "vimrc" "eslintrc")

for i in "${files[@]}"
do
	ln -s ./$i 	~/.$i 

done


