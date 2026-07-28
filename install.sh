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

# On macOS lazygit does NOT read ~/.config unless XDG_CONFIG_HOME is set — it
# looks in ~/Library/Application Support/lazygit. Link both so either works.
if [ "$OS" = "mac" ]; then
  make_link "$DOTFILES_DIR/config/lazygit" "$HOME/Library/Application Support/lazygit"
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

# The binary is useless if its directory isn't reachable.
case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) warn "$HOME/.local/bin is not on \$PATH — lazygit won't be found" ;;
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
