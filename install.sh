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
  thunar brightnessctl playerctl
  fastfetch neovim ripgrep fd
  wl-clipboard grim slurp
  libnotify xdg-user-dirs
  fcitx5 fcitx5-im fcitx5-rime fcitx5-chewing fcitx5-configtool fcitx5-chinese-addons
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

install_oh_my_zsh() {
  echo "==> 4. Installing oh-my-zsh..."
  if [ ! -d "$HOME/.oh-my-zsh/.git" ]; then
    rm -rf "$HOME/.oh-my-zsh"
    git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
  fi
}

install_zsh_plugins() {
  echo "==> 5. Installing Zsh plugins & Powerlevel10k..."
  local custom_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

  mkdir -p "$custom_dir/themes" "$custom_dir/plugins"

  [ -d "$custom_dir/themes/powerlevel10k/.git" ] || \
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$custom_dir/themes/powerlevel10k"

  [ -d "$custom_dir/plugins/zsh-syntax-highlighting/.git" ] || \
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$custom_dir/plugins/zsh-syntax-highlighting"

  [ -d "$custom_dir/plugins/zsh-autosuggestions/.git" ] || \
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git "$custom_dir/plugins/zsh-autosuggestions"
}

setup_zsh_configs() {
  echo "==> 6. Copying Zsh configs..."
  local src_dir="$DOTFILES_DIR/zsh"
  [ -d "$src_dir" ] || return 0

  for file in .zshrc .p10k.zsh; do
    if [ -f "$src_dir/$file" ]; then
      cp -a "$src_dir/$file" "$HOME/$file"
      echo "   $file copied"
    fi
  done

  if [ "${SHELL##*/}" != "zsh" ]; then
    echo "==> Changing default shell to zsh..."
    chsh -s "$(command -v zsh)"
  fi
}

copy_configs() {
  echo "==> 7. Deploying .config directories..."
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
  echo "==> 8. Syncing Pictures..."
  local src="$DOTFILES_DIR/Pictures"
  local dst="$HOME/Pictures"
  [ -d "$src" ] || return 0
  rm -rf "$dst"
  cp -a "$src" "$dst"
}

copy_bin() {
  echo "==> 9. Installing scripts to ~/.local/bin..."
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
  if command -v hyprctl >/dev/null 2>&1; then
    hyprctl dispatch exit && return
  fi
  if command -v loginctl >/dev/null 2>&1 && [ -n "${XDG_SESSION_ID:-}" ]; then
    loginctl terminate-session "$XDG_SESSION_ID" || true
  fi
}

# ------------------------------- Execute ----------------------------------
install_base_pacman
ensure_yay
install_with_yay
install_oh_my_zsh
install_zsh_plugins
setup_zsh_configs
copy_configs
copy_pictures
copy_bin
auto_logout

echo "Installation complete."
