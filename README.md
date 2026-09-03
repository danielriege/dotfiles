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

ghostty   Config: config/ghostty/config — Dracula, SF Mono, castle wallpaper
          behind a dark scrim. Symlinked to ~/.config/ghostty (plus
          ~/Library/Application Support/com.mitchellh.ghostty on mac). One file
          serves both OSes: Ghostty keeps every gtk-* and macos-* key in its
          schema on all platforms, so the irrelevant half just parses and is
          ignored. Asset paths inside it are RELATIVE, resolved against the
          config's own directory, so nothing is hardcoded to one $HOME.
          install.sh additionally installs the xterm-ghostty terminfo entry
          into ~/.terminfo — without it tmux refuses to start under Ghostty.
          The font (Liga SFMono Nerd Font) is NOT vendored: ~50 MB and
          Apple-licensed. install.sh warns if it is missing; the config falls
          back to SF Mono / Menlo / DejaVu Sans Mono.
          Machine-specific tweaks go in config/ghostty/local.conf (git-ignored).
