#!/usr/bin/env bash

# Dotfiles deployer for small-R (Austin)
# Target: Arch Linux + Hyprland + Zsh (p10k)
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
echo "==> Starting dotfiles deployment from ${DOTFILES_DIR}"

# ------------------------------- Configuration ----------------------------
BASE_PACMAN_PKGS=(base-devel git zsh)

YAY_PKGS=(
  curl unzip
  hyprland hyprlock waybar kitty wlogout swaync rofi-wayland
  fastfetch neovim ripgrep fd
  wl-clipboard grim slurp
  libnotify xdg-user-dirs
  fcitx5 fcitx5-im fcitx5-rime fcitx5-chewing fcitx5-configtool fcitx5-chinese-addons
  oh-my-zsh-git
  hyprshot
  matugen-bin
  awww
  ttf-jetbrains-mono-nerd
)

# ------------------------------- Functions --------------------------------

install_base_pacman() {
  echo "==> 1. Installing base build deps..."
  for pkg in "${BASE_PACMAN_PKGS[@]}"; do
    sudo pacman -S --needed --noconfirm "$pkg"
  done
}

ensure_yay() {
  if ! command -v yay >/dev/null 2>&1; then
    echo "==> 2. Installing yay (AUR helper)..."
    local tmpdir
    tmpdir="$(mktemp -d)"
    git clone https://aur.archlinux.org/yay-bin.git "$tmpdir/yay-bin"
    (cd "$tmpdir/yay-bin" && makepkg -si --noconfirm)
  fi
}

install_with_yay() {
  echo "==> 3. Installing packages via yay..."
  for pkg in "${YAY_PKGS[@]}"; do
    yay -S --needed --noconfirm "$pkg"
  done
}

install_zsh_plugins() {
  echo "==> 4. Setting up Zsh plugins & Powerlevel10k..."
  local custom_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
  
  # Powerlevel10k
  [ -d "$custom_dir/themes/powerlevel10k" ] || \
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$custom_dir/themes/powerlevel10k"
  
  # Plugins
  [ -d "$custom_dir/plugins/zsh-syntax-highlighting" ] || \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$custom_dir/plugins/zsh-syntax-highlighting"
  [ -d "$custom_dir/plugins/zsh-autosuggestions" ] || \
    git clone https://github.com/zsh-users/zsh-autosuggestions.git "$custom_dir/plugins/zsh-autosuggestions"
}

setup_zsh_configs() {
  echo "==> 5. Syncing Zsh configurations (Smart Symlink)..."
  local src_dir="$DOTFILES_DIR/zsh"
  local files=(".zshrc" ".p10k.zsh")
  mkdir -p "$src_dir"

  for file in "${files[@]}"; do
    local src="$src_dir/$file"
    local dst="$HOME/$file"

    if [ -f "$src" ]; then
      echo "   [Deploy] Linking $file -> $HOME"
      # 安全備份：如果是實體檔案則重新命名
      [ -f "$dst" ] && [ ! -L "$dst" ] && mv "$dst" "${dst}.bak"
      ln -sf "$src" "$dst"
    elif [ -f "$dst" ]; then
      echo "   [Init] Moving $file to dotfiles and linking back"
      mv "$dst" "$src"
      ln -sf "$src" "$dst"
    else
      echo "   [Create] Creating template $file"
      touch "$src"
      ln -sf "$src" "$dst"
    fi
  done

  # 切換預設 Shell
  if [[ "${SHELL##*/}" != "zsh" ]]; then
    echo "==> Changing default shell to zsh..."
    chsh -s "$(which zsh)"
  fi
}

copy_configs() {
  echo "==> 6. Deploying .config directories..."
  local src="$DOTFILES_DIR/config"
  local dst="$HOME/.config"
  [ -d "$src" ] || return 0
  mkdir -p "$dst"
  for item in "$src"/*; do
    [ -e "$item" ] || continue
    local name="$(basename "$item")"
    rm -rf "$dst/$name"
    cp -a "$item" "$dst/$name"
    echo "   .config/$name copied"
  done
}

copy_pictures() {
  echo "==> 7. Syncing Pictures..."
  local src="$DOTFILES_DIR/Pictures"
  local dst="$HOME/Pictures"
  [ -d "$src" ] || return 0
  rm -rf "$dst"
  cp -a "$src" "$dst"
}

copy_bin() {
  echo "==> 8. Installing scripts to ~/.local/bin..."
  local src="$DOTFILES_DIR/bin"
  local dst="$HOME/.local/bin"
  [ -d "$src" ] || return 0
  mkdir -p "$dst"
  cp -a "$src"/. "$dst"/
  chmod +x "$dst"/* 2>/dev/null || true
}

auto_logout() {
  [ -n "${NO_AUTO_LOGOUT:-}" ] && return
  echo "==> Done! Logging out in 5s to apply changes (Ctrl+C to cancel)..."
  sleep 5
  hyprctl dispatch exit || loginctl terminate-session "$XDG_SESSION_ID" || true
}

# ------------------------------- Execute ----------------------------------
install_base_pacman
ensure_yay
install_with_yay
install_zsh_plugins
setup_zsh_configs
copy_configs
copy_pictures
copy_bin
auto_logout

echo "Installation complete."