#!/usr/bin/env bash

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
  noto-fonts-cjk
  adobe-source-han-sans-tw-fonts
  ascii-image-converter-git
  rsync
  expect
  nodejs
  npm
  firefox
  pear-desktop
  vencord
  cava
  cmatrix
  tty-clock
  btop
)

# ------------------------------- Functions --------------------------------

install_base_pacman() {
  echo "==> 1. Installing base packages..."
  for pkg in "${BASE_PACMAN_PKGS[@]}"; do
    sudo pacman -S --needed --noconfirm "$pkg"
  done
}

update_system() {
  echo "==> Updating package database..."
  sudo pacman -Syyu --noconfirm
}

ensure_yay() {
  if ! command -v yay >/dev/null 2>&1; then
    echo "==> 2. Installing yay..."
    tmpdir="$(mktemp -d)"
    git clone https://aur.archlinux.org/yay-bin.git "$tmpdir/yay-bin"
    (cd "$tmpdir/yay-bin" && makepkg -si --noconfirm)
  fi
}

install_with_yay() {
  echo "==> 3. Installing packages..."
  for pkg in "${YAY_PKGS[@]}"; do
    yay -S --needed --noconfirm \
      --answerdiff None \
      --answerclean None \
      "$pkg"
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
  echo "==> 5. Installing zsh plugins..."
  custom_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

  mkdir -p "$custom_dir/themes" "$custom_dir/plugins"

  [ -d "$custom_dir/themes/powerlevel10k" ] || \
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$custom_dir/themes/powerlevel10k"

  [ -d "$custom_dir/plugins/zsh-syntax-highlighting" ] || \
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$custom_dir/plugins/zsh-syntax-highlighting"

  [ -d "$custom_dir/plugins/zsh-autosuggestions" ] || \
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git "$custom_dir/plugins/zsh-autosuggestions"
}

setup_zsh_configs() {
  echo "==> 6. Copying zsh configs..."
  src="$DOTFILES_DIR/zsh"
  [ -d "$src" ] || return 0

  for file in .zshrc .p10k.zsh; do
    [ -f "$src/$file" ] && cp -a "$src/$file" "$HOME/$file"
  done

  if [ "${SHELL##*/}" != "zsh" ]; then
    chsh -s "$(command -v zsh)"
  fi
}

copy_configs() {
  echo "==> 7. Syncing .config..."
  src="$DOTFILES_DIR/config"
  dst="$HOME/.config"
  [ -d "$src" ] || return 0

  mkdir -p "$dst"

  rsync -av \
    --delete \
    --exclude 'waybar/colors.css' \
    --exclude 'hypr/colors.conf' \
    --exclude 'kitty/colors.conf' \
    --exclude 'swaync/colors/' \
    "$src/" "$dst/"
}

copy_local_share() {
  echo "==> 8. Syncing local-share..."
  src="$DOTFILES_DIR/local-share"
  dst="$HOME/.local/share"
  [ -d "$src" ] || return 0

  mkdir -p "$dst"

  rsync -av "$src/" "$dst/"
}

copy_pictures() {
  echo "==> 9. Syncing Pictures..."
  src="$DOTFILES_DIR/Pictures"
  dst="$HOME/Pictures"
  [ -d "$src" ] || return 0

  rm -rf "$dst"
  cp -a "$src" "$dst"
}

copy_bin() {
  echo "==> 10. Syncing bin..."
  src="$DOTFILES_DIR/bin"
  dst="$HOME/.local/bin"
  [ -d "$src" ] || return 0

  mkdir -p "$dst"

  rsync -av --delete "$src/" "$dst/"
  chmod +x "$dst"/* 2>/dev/null || true
}

reload_services() {
  echo "==> Reloading services..."
  command -v fcitx5-remote >/dev/null && fcitx5-remote -r || true
}

auto_logout() {
  [ -n "${NO_AUTO_LOGOUT:-}" ] && return

  echo "==> Logging out in 5s..."
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
update_system
ensure_yay
install_with_yay
install_oh_my_zsh
install_zsh_plugins
setup_zsh_configs
copy_configs
copy_local_share
copy_pictures
copy_bin
reload_services
auto_logout

echo "Installation complete."
