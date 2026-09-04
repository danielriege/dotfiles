#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Detect OS ─────────────────────────────────────────────────────────────────
OS="$(uname -s)"
case "$OS" in
  Darwin*) OS=mac ;;
  Linux*)  OS=linux ;;
  *) echo "Unsupported OS: $OS" && exit 1 ;;
esac

# ── Helpers ───────────────────────────────────────────────────────────────────
info()    { echo "  [..] $*"; }
ok()      { echo "  [ok] $*"; }
warn()    { echo "  [!!] $*"; }

# Create symlink src→dst, backing up any existing file/dir first.
make_link() {
  local src="$1"
  local dst="$2"

  # Already the correct symlink — nothing to do
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    ok "symlink already correct: $dst"
    return
  fi

  # Back up whatever's there so we don't silently destroy work
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    local backup="${dst}.bak.$(date +%s)"
    warn "backing up $dst → $backup"
    mv "$dst" "$backup"
  fi

  mkdir -p "$(dirname "$dst")"
  ln -s "$src" "$dst"
  ok "linked $dst → $src"
}

# Portable in-place sed (macOS needs the empty-string extension arg)
sed_inplace() {
  if [ "$OS" = "mac" ]; then
    sed -i '' "$@"
  else
    sed -i "$@"
  fi
}

# ── oh-my-zsh ─────────────────────────────────────────────────────────────────
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  info "installing oh-my-zsh"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  ok "oh-my-zsh already installed"
fi

# ── Symlink configs ───────────────────────────────────────────────────────────
mkdir -p "$HOME/.config"
make_link "$DOTFILES_DIR/config/nvim" "$HOME/.config/nvim"
make_link "$DOTFILES_DIR/config/tmux" "$HOME/.config/tmux"
make_link "$DOTFILES_DIR/config/lazygit" "$HOME/.config/lazygit"
make_link "$DOTFILES_DIR/config/ghostty" "$HOME/.config/ghostty"

# On macOS lazygit does NOT read ~/.config unless XDG_CONFIG_HOME is set — it
# looks in ~/Library/Application Support/lazygit. Link both so either works.
if [ "$OS" = "mac" ]; then
  make_link "$DOTFILES_DIR/config/lazygit" "$HOME/Library/Application Support/lazygit"

  # Ghostty DOES read ~/.config/ghostty on macOS, so the link above is already
  # enough. This second link exists because macOS loads the Application Support
  # copy AFTER the XDG one, meaning a stale file left there would silently win
  # over the repo config. Pointing both at the same directory makes that
  # impossible instead of merely unlikely.
  make_link "$DOTFILES_DIR/config/ghostty" "$HOME/Library/Application Support/com.mitchellh.ghostty"
fi

# ── SF Mono (macOS) ───────────────────────────────────────────────────────────
# Apple ships SF Mono only inside Terminal.app's bundle, where it is NOT a
# registered font — apps like Ghostty can't see it and quietly fall back to
# something else. Copying it into ~/Library/Fonts registers it. `cp -n` so a
# newer hand-installed copy is never clobbered.
if [ "$OS" = "mac" ]; then
  SFMONO_SRC="/System/Applications/Utilities/Terminal.app/Contents/Resources/Fonts"
  if [ -f "$HOME/Library/Fonts/SF-Mono-Regular.otf" ]; then
    ok "SF Mono already installed"
  elif compgen -G "$SFMONO_SRC/SF-Mono-*.otf" >/dev/null; then
    info "installing SF Mono from Terminal.app"
    mkdir -p "$HOME/Library/Fonts"
    cp -n "$SFMONO_SRC"/SF-Mono-*.otf "$HOME/Library/Fonts/"
    ok "SF Mono → ~/Library/Fonts"
  else
    warn "SF Mono not found in Terminal.app — Ghostty will fall back to JetBrains Mono"
  fi
fi

# ── TPM ───────────────────────────────────────────────────────────────────────
# tpm lives inside config/tmux/plugins/tpm which is now symlinked, so it's
# already available. Only clone if somehow missing (e.g. fresh checkout without
# the nested repo populated).
if [ ! -d "$HOME/.config/tmux/plugins/tpm" ]; then
  info "installing tpm"
  git clone https://github.com/tmux-plugins/tpm "$HOME/.config/tmux/plugins/tpm"
else
  ok "tpm already present"
fi

# Install tmux plugins headlessly
if [ -x "$HOME/.config/tmux/plugins/tpm/scripts/install_plugins.sh" ]; then
  info "installing tmux plugins"
  TMUX_PLUGIN_MANAGER_PATH="$HOME/.config/tmux/plugins" \
    "$HOME/.config/tmux/plugins/tpm/scripts/install_plugins.sh"
fi

# ── Apply tmux plugin patches ─────────────────────────────────────────────
PLAYERCTL_SCRIPT="$HOME/.config/tmux/plugins/tmux/scripts/playerctl.sh"
PLAYERCTL_PATCH="$DOTFILES_DIR/config/tmux/patches/playerctl-no-scroll.patch"
if [ -f "$PLAYERCTL_SCRIPT" ] && [ -f "$PLAYERCTL_PATCH" ]; then
  info "patching playerctl plugin (disable scrolling)"
  patch -N -p1 "$PLAYERCTL_SCRIPT" < "$PLAYERCTL_PATCH" \
    && ok "playerctl patched" \
    || warn "playerctl patch skipped (already applied or conflict)"
fi

# ── Ghostty terminfo ──────────────────────────────────────────────────────────
# config/ghostty/config sets `term = xterm-ghostty` so no terminal capabilities
# are thrown away. The catch: that terminfo entry ships WITH Ghostty but is
# usually absent from the system terminfo database, and without it tmux refuses
# to start at all — "missing or unsuitable terminal: xterm-ghostty".
#
# Goes into ~/.terminfo, so no sudo. Note the METHOD: pipe infocmp through tic
# rather than copying the compiled file. ncurses names its subdirectories
# differently per platform — letters on Linux (x/xterm-ghostty), hex on macOS
# (78/xterm-ghostty) — and letting tic do the compiling means the local
# convention is used automatically instead of us hardcoding a guess.
if infocmp xterm-ghostty >/dev/null 2>&1; then
  ok "xterm-ghostty terminfo already available"
else
  GHOSTTY_TI=""
  for d in \
    /snap/ghostty/current/share/terminfo \
    /usr/share/terminfo \
    /usr/local/share/terminfo \
    /var/lib/flatpak/app/com.mitchellh.ghostty/current/active/files/share/terminfo \
    "$HOME/.local/share/terminfo" \
    /Applications/Ghostty.app/Contents/Resources/terminfo \
    "$HOME/Applications/Ghostty.app/Contents/Resources/terminfo"
  do
    if [ -d "$d" ] && infocmp -A "$d" xterm-ghostty >/dev/null 2>&1; then
      GHOSTTY_TI="$d"
      break
    fi
  done

  if [ -z "$GHOSTTY_TI" ]; then
    warn "xterm-ghostty terminfo not found — tmux will refuse to start in Ghostty"
    warn "  install Ghostty first, then re-run this script"
  else
    info "installing xterm-ghostty terminfo from $GHOSTTY_TI"
    # tic emits a harmless note about the description field on older ncurses;
    # both streams are silenced so it cannot trip `set -e` or look like a fault.
    if infocmp -A "$GHOSTTY_TI" -x xterm-ghostty 2>/dev/null \
         | tic -x -o "$HOME/.terminfo" - 2>/dev/null; then
      ok "xterm-ghostty terminfo → ~/.terminfo"
    else
      warn "tic failed to compile the xterm-ghostty terminfo entry"
    fi
  fi
fi

# ── Ghostty font ──────────────────────────────────────────────────────────────
# config/ghostty/config asks for "Liga SFMono Nerd Font": ligaturised SF Mono
# with the Nerd Font glyph patch, which is what stops the Dracula tmux status
# line and powerline separators rendering as tofu boxes.
#
# NOT vendored into this repo, deliberately. The 12 OTFs come to ~50 MB, and
# SF Mono is Apple-licensed — redistributing it from a public GitHub remote is
# not ours to do. The config lists SF Mono, Menlo and DejaVu Sans Mono as
# fallbacks so a machine without it still gets a sane monospace, just without
# the Nerd Font glyphs. Hence a warning here rather than an install step.
case "$OS" in
  mac)   FONT_DIR="$HOME/Library/Fonts" ;;
  linux) FONT_DIR="$HOME/.local/share/fonts" ;;
esac

ghostty_font_present() {
  case "$OS" in
    linux)
      command -v fc-list >/dev/null 2>&1 \
        && fc-list 2>/dev/null | grep -qi "SFMono Nerd Font"
      ;;
    mac)
      ls "$HOME/Library/Fonts" /Library/Fonts 2>/dev/null | grep -qi "SFMono"
      ;;
  esac
}

if ghostty_font_present; then
  ok "SFMono Nerd Font present"
else
  warn "Liga SFMono Nerd Font not installed"
  warn "  Ghostty falls back to SF Mono / Menlo / DejaVu Sans Mono, but Nerd Font"
  warn "  glyphs (tmux status line, powerline separators) will show as boxes."
  warn "  Drop the LigaSFMonoNerdFont-*.otf files into $FONT_DIR and re-run."
fi

# ── lazygit ───────────────────────────────────────────────────────────────────
# Pinned version, installed into ~/.local/bin (no sudo needed — Ubuntu only
# ships lazygit in apt from 24.10 onward, and a system-wide install would make
# this script prompt for a password halfway through).
#
# To upgrade: bump LAZYGIT_VERSION and re-run. config/lazygit/config.yml sets
# `update: method: never` so lazygit can't self-update behind the dotfiles' back
# and leave the binary out of sync with what's pinned here.
LAZYGIT_VERSION="0.63.1"
LAZYGIT_BIN="$HOME/.local/bin/lazygit"

if [ -x "$LAZYGIT_BIN" ] && "$LAZYGIT_BIN" --version 2>/dev/null | grep -q "version=$LAZYGIT_VERSION"; then
  ok "lazygit $LAZYGIT_VERSION already installed"
else
  # Assets are named lazygit_<ver>_<Linux|Darwin>_<x86_64|arm64>.tar.gz
  case "$OS" in
    mac)   LG_OS="Darwin" ;;
    linux) LG_OS="Linux"  ;;
  esac
  case "$(uname -m)" in
    x86_64 | amd64)  LG_ARCH="x86_64" ;;
    arm64 | aarch64) LG_ARCH="arm64"  ;;
    *)               LG_ARCH=""       ;;
  esac

  if [ -z "$LG_ARCH" ]; then
    warn "unrecognised arch $(uname -m) — skipping lazygit"
  else
    info "installing lazygit $LAZYGIT_VERSION ($LG_OS/$LG_ARCH)"
    LG_TMP="$(mktemp -d)"
    LG_URL="https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_${LG_OS}_${LG_ARCH}.tar.gz"

    # Guarded with `if` so a network hiccup warns instead of killing the whole
    # script under `set -e`.
    if curl -fsSL "$LG_URL" -o "$LG_TMP/lazygit.tar.gz"; then
      tar -xzf "$LG_TMP/lazygit.tar.gz" -C "$LG_TMP" lazygit
      mkdir -p "$(dirname "$LAZYGIT_BIN")"
      # Plain `install -m`: GNU's -D flag does not exist on BSD/macOS install.
      install -m 755 "$LG_TMP/lazygit" "$LAZYGIT_BIN"
      ok "lazygit $LAZYGIT_VERSION → $LAZYGIT_BIN"
    else
      warn "lazygit download failed — skipping ($LG_URL)"
    fi
    rm -rf "$LG_TMP"
  fi
fi

# ── delta ─────────────────────────────────────────────────────────────────────
# Diff pager used by lazygit (see git.pagers in config/lazygit/config.yml).
# Same pinned-tarball approach as lazygit above, and for the same reason: apt's
# git-delta needs root, and on Ubuntu 24.04 it's 0.16.5 — three minor versions
# behind.
#
# Two things differ from the lazygit block:
#   1. delta's git tags carry NO leading "v" (0.19.2, not v0.19.2).
#   2. its tarball nests everything under delta-<ver>-<triple>/, so the extract
#      needs --strip-components=1 (bsdtar and GNU tar both support it).
DELTA_VERSION="0.19.2"
DELTA_BIN="$HOME/.local/bin/delta"

if [ -x "$DELTA_BIN" ] && "$DELTA_BIN" --version 2>/dev/null | grep -q "delta $DELTA_VERSION"; then
  ok "delta $DELTA_VERSION already installed"
else
  # Assets are named delta-<ver>-<rust-target-triple>.tar.gz. The triple can't
  # be composed from OS+arch the way lazygit's can: upstream ships no
  # x86_64-apple-darwin build at all, and arm64 Linux is gnu-only (no musl).
  # So map the whole thing explicitly and let unlisted combos fall through.
  case "$OS/$(uname -m)" in
    linux/x86_64 | linux/amd64)   DELTA_TRIPLE="x86_64-unknown-linux-musl" ;;
    linux/arm64 | linux/aarch64)  DELTA_TRIPLE="aarch64-unknown-linux-gnu" ;;
    mac/arm64 | mac/aarch64)      DELTA_TRIPLE="aarch64-apple-darwin" ;;
    *)                            DELTA_TRIPLE="" ;;
  esac

  if [ -z "$DELTA_TRIPLE" ]; then
    # Intel Macs land here. Not fatal to this script, but it does leave lazygit
    # broken: it will NOT fall back to its builtin renderer — the diff pane just
    # reports "delta not found". Either build delta from source or comment out
    # git.pagers in config/lazygit/config.yml on such a machine.
    warn "no prebuilt delta for $OS/$(uname -m) — skipping (lazygit's diff pane will error until git.pagers is removed)"
  else
    info "installing delta $DELTA_VERSION ($DELTA_TRIPLE)"
    DT_TMP="$(mktemp -d)"
    DT_DIR="delta-${DELTA_VERSION}-${DELTA_TRIPLE}"
    DT_URL="https://github.com/dandavison/delta/releases/download/${DELTA_VERSION}/${DT_DIR}.tar.gz"

    # Guarded with `if` so a network hiccup warns instead of killing the whole
    # script under `set -e`.
    if curl -fsSL "$DT_URL" -o "$DT_TMP/delta.tar.gz"; then
      tar -xzf "$DT_TMP/delta.tar.gz" -C "$DT_TMP" --strip-components=1 "$DT_DIR/delta"
      mkdir -p "$(dirname "$DELTA_BIN")"
      install -m 755 "$DT_TMP/delta" "$DELTA_BIN"
      ok "delta $DELTA_VERSION → $DELTA_BIN"
    else
      warn "delta download failed — skipping ($DT_URL)"
    fi
    rm -rf "$DT_TMP"
  fi
fi

# Those binaries are useless if their directory isn't reachable.
case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) warn "$HOME/.local/bin is not on \$PATH — lazygit and delta won't be found" ;;
esac

# ── powerlevel10k ─────────────────────────────────────────────────────────────
P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
if [ ! -d "$P10K_DIR" ]; then
  info "installing powerlevel10k"
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
else
  ok "powerlevel10k already installed"
fi

# ── Patch .zshrc ──────────────────────────────────────────────────────────────
ZSHRC="$HOME/.zshrc"
if [ -f "$ZSHRC" ]; then
  sed_inplace 's|ZSH_THEME=".*"|ZSH_THEME="powerlevel10k/powerlevel10k"|' "$ZSHRC"
  sed_inplace 's/plugins=(git)/plugins=()/' "$ZSHRC"
  ok "patched .zshrc"

  # lazygit alias. Guarded by a marker so re-running never duplicates the block.
  if grep -q "# >>> dotfiles: lazygit" "$ZSHRC"; then
    ok "lg alias already present"
  else
    info "adding lg alias to .zshrc"
    cat >>"$ZSHRC" <<'EOF'

# >>> dotfiles: lazygit
alias lg='lazygit'
# <<< dotfiles: lazygit
EOF
    ok "added alias lg='lazygit'"
  fi
else
  warn ".zshrc not found — skipping zsh patches"
fi

echo ""
ok "done. restart your terminal or: source ~/.zshrc"
