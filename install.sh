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
else
  warn ".zshrc not found — skipping zsh patches"
fi

echo ""
ok "done. restart your terminal or: source ~/.zshrc"
