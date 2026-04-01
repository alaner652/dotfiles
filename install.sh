#!/usr/bin/env bash

# Dotfiles deployer for fresh Arch installs.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
echo "==> Installing dotfiles from ${DOTFILES_DIR}"

# ------------------------------- Helpers ----------------------------------
# Minimal base via pacman (for building yay itself)
BASE_PACMAN_PKGS=(base-devel git zsh)

# Everything else (official + AUR) handled by yay
YAY_PKGS=(
  curl unzip
  hyprland hyprlock waybar kitty wlogout swaync rofi-wayland
  fastfetch neovim ripgrep fd
  wl-clipboard grim slurp
  libnotify xdg-user-dirs
  fcitx5 fcitx5-im fcitx5-rime fcitx5-chewing fcitx5-configtool fcitx5-chinese-addons
  oh-my-zsh
  hyprshot
  matugen-bin
  awww            # wallpaper daemon/cli used by wallset + hypr autostart
)

install_base_pacman() {
  echo "==> Installing base build deps via pacman..."
  local pkg
  for pkg in "${BASE_PACMAN_PKGS[@]}"; do
    pacman -Qi "$pkg" &>/dev/null && continue
    if ! sudo pacman -S --needed --noconfirm "$pkg"; then
      echo "!! pacman install failed for $pkg (skipping, yay may fail if missing)"
    fi
  done
}

ensure_yay() {
  if command -v yay >/dev/null 2>&1; then
    return
  fi
  echo "==> Installing yay (AUR helper)..."
  tmpdir="$(mktemp -d)"
  git clone https://aur.archlinux.org/yay-bin.git "$tmpdir/yay-bin"
  (cd "$tmpdir/yay-bin" && makepkg -si --noconfirm)
}

install_with_yay() {
  echo "==> Installing packages via yay (official + AUR)..."
  local pkg
  for pkg in "${YAY_PKGS[@]}"; do
    yay -Qi "$pkg" &>/dev/null && continue
    if ! yay -S --needed --noconfirm "$pkg"; then
      echo "!! yay install failed for $pkg (skipping)"
    fi
  done
}

copy_configs() {
  local src="$DOTFILES_DIR/config"
  local dst="$HOME/.config"
  [ -d "$src" ] || return 0
  mkdir -p "$dst"
  for item in "$src"/*; do
    [ -e "$item" ] || continue
    local name
    name="$(basename "$item")"
    rm -rf "$dst/$name"
    cp -a "$item" "$dst/$name"
    echo "   .config/$name copied"
  done
}

copy_pictures() {
  local src="$DOTFILES_DIR/Pictures"
  local dst="$HOME/Pictures"
  [ -d "$src" ] || return 0
  rm -rf "$dst"
  cp -a "$src" "$dst"
  echo "   Pictures replaced"
}

copy_bin() {
  local src="$DOTFILES_DIR/bin"
  local dst="$HOME/.local/bin"
  [ -d "$src" ] || return 0
  mkdir -p "$dst"
  cp -a "$src"/. "$dst"/
  find "$dst" -maxdepth 1 -type f -print0 | xargs -0 --no-run-if-empty chmod +x
  echo "   bin scripts copied to ~/.local/bin"
}

auto_logout() {
  [ -n "${NO_AUTO_LOGOUT:-}" ] && { echo "Skip auto-logout (NO_AUTO_LOGOUT set)"; return; }
  echo "==> Logging out in 5 seconds to apply shell/env (Ctrl+C to cancel)..."
  sleep 5
  if command -v hyprctl >/dev/null 2>&1; then
    hyprctl dispatch exit || true
    return
  fi
  if command -v loginctl >/dev/null 2>&1 && [ -n "${XDG_SESSION_ID:-}" ]; then
    loginctl terminate-session "$XDG_SESSION_ID" || true
    return
  fi
  # Fallback: log out via pkill of session leader shell (best-effort)
  if [ -n "${SSH_TTY:-}" ]; then
    pkill -KILL -t "$(ps -o tty= -p "$$" | tr -d ' ')" || true
  fi
}

# ------------------------------- Run --------------------------------------
install_base_pacman
ensure_yay
install_with_yay
copy_configs
copy_pictures
copy_bin
auto_logout

echo "Done. (Set NO_AUTO_LOGOUT=1 to skip logout when rerunning.)"
