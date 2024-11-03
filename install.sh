#!/usr/bin/env zsh

# install oh-my-zsh if not installed
if [ ! -d ~/.oh-my-zsh ]; then
	echo "Installing oh-my-zsh"
	sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
	echo "oh-my-zsh already installed"
fi

cp -r config/nvim ~/.config/ 
cp -r config/tmux ~/.config/ 

# install tpm
if [ ! -d ~/.config/tmux/plugins/tpm ]; then
  git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
fi
# installing tmux plugins
echo "Installing tmux plugins"
~/.config/tmux/plugins/tpm/scripts/install_plugins.sh

# installing dracula theme for oh-my-zsh
if [ ! -d ~/.oh-my-zsh/custom/themes/powerlevel10k ]; then
	echo "Installing powerlevel10k theme for oh-my-zsh"
	git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k
fi
sed -i 's|ZSH_THEME=".*"|ZSH_THEME="powerlevel10k/powerlevel10k"|' ~/.zshrc

# .zshrc configs
# remove git plugin
sed -i 's/plugins=(git)/plugins=()/' ~/.zshrc

