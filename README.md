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
          into ~/.terminfo (without it tmux refuses to start under Ghostty),
          and on macOS copies SF Mono out of Terminal.app into
          ~/Library/Fonts, where it is otherwise unregistered.
          The Nerd Font patch (Liga SFMono Nerd Font) is NOT vendored: ~50 MB
          and Apple-licensed. install.sh warns if it is missing; the config
          falls back to SF Mono / Menlo / DejaVu Sans Mono.
          Machine-specific tweaks (e.g. a larger font-size on macOS) go in
          config/ghostty/local.conf (git-ignored).

Shared scripts (Linux and macOS):

Run `./install.sh` to add `setup` and `ozzy` aliases to `.zshrc`, pointing directly
at the scripts in this checkout. Reload it with `source ~/.zshrc`, or call
`./scripts/tmux_setup.sh` from the repo directly.

From inside an existing tmux session:

```sh
setup ~/code/my-repo                        # lazygit, nvim, Claude, shell
setup ~/code/my-worktree --agent codex      # same layout with Codex
setup -v --agent ozzy ~/code/my-repo        # lazygit + Ozzy-flavoured Claude
setup -v                                    # two panes for the current repo
setup                                       # home: spotify, btop, shell, agent
```

`--agent` (or `-a`) accepts `claude`, `codex`, or `ozzy`. The default is `claude`;
set `export TMUX_SETUP_AGENT=codex` in your shell config to change it per machine.
An explicit `--agent` overrides that default, including in the home layout.

Each project pane activates the repo's `.venv/bin/activate` if it exists. A
linked Git worktree without its own activation script uses the main checkout's
instead. If neither exists, activation is skipped and the tools still start.
Paths inside a Git checkout resolve to its root; plain directories are also
accepted, with only their own `.venv` considered. Paths with spaces work.

The scripts support Bash and Zsh pane shells and require tmux, lazygit, the
selected agent's CLI on PATH, and nvim for the full layout. Git supplies the
worktree detection. The home layout additionally uses spotify and btop.
`ozzy-claude.sh` forwards its arguments to Claude and adds the persona prompt;
machine-specific Claude options can be passed explicitly, for example
`ozzy --dangerously-load-development-channels server:jenkins`.
