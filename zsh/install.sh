#!/usr/bin/env bash
# Install oh-my-zsh + plugins/theme and symlink ~/.zshrc and ~/.p10k.zsh
# from this repo. Idempotent — safe to re-run; only installs/clones what's
# missing and won't overwrite existing symlinks.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OMZ_DIR="${ZSH:-$HOME/.oh-my-zsh}"
OMZ_CUSTOM="${ZSH_CUSTOM:-$OMZ_DIR/custom}"

# 1. oh-my-zsh
if [ ! -d "$OMZ_DIR" ]; then
  echo "==> Installing oh-my-zsh"
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "==> oh-my-zsh already installed"
fi

# 2. Custom plugins / theme — clone if missing, leave alone otherwise
clone_if_missing() {
  local url="$1" dest="$2"
  if [ -d "$dest" ]; then
    echo "==> $(basename "$dest") already present"
  else
    echo "==> Cloning $(basename "$dest")"
    git clone --depth=1 "$url" "$dest"
  fi
}

clone_if_missing https://github.com/zsh-users/zsh-autosuggestions.git \
  "$OMZ_CUSTOM/plugins/zsh-autosuggestions"
clone_if_missing https://github.com/zsh-users/zsh-syntax-highlighting.git \
  "$OMZ_CUSTOM/plugins/zsh-syntax-highlighting"
clone_if_missing https://github.com/romkatv/powerlevel10k.git \
  "$OMZ_CUSTOM/themes/powerlevel10k"

# 3. Symlink configs into $HOME — back up real files first, leave existing
#    symlinks alone (they're presumed correct)
link_config() {
  local src="$1" target="$2"
  if [ -L "$target" ]; then
    echo "==> $target already a symlink, leaving alone"
    return
  fi
  if [ -e "$target" ]; then
    local backup="$target.bak.$(date +%Y%m%d-%H%M%S)"
    echo "==> Backing up existing $target → $backup"
    mv "$target" "$backup"
  fi
  echo "==> Linking $target → $src"
  ln -s "$src" "$target"
}

link_config "$REPO_DIR/zshrc" "$HOME/.zshrc"
link_config "$REPO_DIR/p10k.zsh" "$HOME/.p10k.zsh"

echo
echo "Done. Open a new zsh shell or run: exec zsh"
