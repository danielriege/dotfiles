Package requirements for tiling window manager:

cava
thunar
pavucontrol
xfce4-power-manager
alacritty
rofi
lightdm
lightdm-gtk-greeter (also the settings util)
feh
dunst
lxappearance
pass
spotifytui
cava
playerctl
ripgrep

Installed by install.sh (do NOT install these by hand):

lazygit   version pinned as LAZYGIT_VERSION in install.sh, fetched from the
          GitHub release tarball into ~/.local/bin (apt has no lazygit before
          Ubuntu 24.10, and this way needs no sudo). Upgrade by bumping that
          variable and re-running install.sh.
          Config: config/lazygit/config.yml — Dracula theme, symlinked to
          ~/.config/lazygit (plus ~/Library/Application Support/lazygit on mac).
          Aliased to `lg` in .zshrc.
