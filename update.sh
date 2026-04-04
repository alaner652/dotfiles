#!/usr/bin/env bash
set -euo pipefail

CONFIG_SRC="$HOME/.config"
CONFIG_DST="$HOME/small-R/dotfiles/config"

BIN_SRC="$HOME/.local/bin"
BIN_DST="$HOME/small-R/dotfiles/bin"

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

echo "==> Syncing bin..."

mkdir -p "$BIN_DST"

rsync -av \
  --delete \
  "$BIN_SRC/" "$BIN_DST/"

echo "==> Done."
