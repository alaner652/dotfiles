#!/usr/bin/env bash
set -euo pipefail

CONFIG_SRC="$HOME/.config"
CONFIG_DST="$HOME/dotfiles/config"

BIN_SRC="$HOME/.local/bin"
BIN_DST="$HOME/dotfiles/bin"

LOCAL_SHARE_SRC="$HOME/.local/share"
LOCAL_SHARE_DST="$HOME/dotfiles/local-share"

echo "==> Syncing configs..."

mkdir -p "$CONFIG_DST"

CONFIGS=(
  hypr
  waybar
  kitty
  rofi
  swaync
  fastfetch
  nvim
  fcitx5
)

for dir in "${CONFIGS[@]}"; do
  if [ -d "$CONFIG_SRC/$dir" ]; then
    echo "==> Syncing config/$dir"

    rsync -av \
      --delete \
      --exclude 'colors.css' \
      --exclude 'colors.conf' \
      --exclude 'colors/' \
      --exclude '*.cache' \
      --exclude '*.log' \
      "$CONFIG_SRC/$dir/" "$CONFIG_DST/$dir/"
  fi
done

echo "==> Syncing fcitx5 user data..."

mkdir -p "$LOCAL_SHARE_DST"

rsync -av \
  --delete \
  --exclude '*.cache' \
  "$LOCAL_SHARE_SRC/fcitx5/" "$LOCAL_SHARE_DST/fcitx5/" 2>/dev/null || true

echo "==> Syncing bin..."

mkdir -p "$BIN_DST"

rsync -av \
  --delete \
  "$BIN_SRC/" "$BIN_DST/"

echo "==> Done."