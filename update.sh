#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

CONFIG_SRC="$HOME/.config"
CONFIG_DST="$DOTFILES_DIR/config"

BIN_SRC="$HOME/.local/bin"
BIN_DST="$DOTFILES_DIR/bin"

LOCAL_SHARE_SRC="$HOME/.local/share"
LOCAL_SHARE_DST="$DOTFILES_DIR/local-share"

ZSH_SRC="$HOME"
ZSH_DST="$DOTFILES_DIR/zsh"

PICTURES_SRC="$HOME/Pictures"
PICTURES_DST="$DOTFILES_DIR/Pictures"

echo "==> Syncing configs..."
mkdir -p "$CONFIG_DST"

rsync -av \
  --delete \
  --exclude 'waybar/colors.css' \
  --exclude 'hypr/colors.conf' \
  --exclude 'kitty/colors.conf' \
  --exclude 'swaync/colors/' \
  "$CONFIG_SRC/" "$CONFIG_DST/"

echo "==> Syncing local-share..."
mkdir -p "$LOCAL_SHARE_DST"
rsync -av --delete "$LOCAL_SHARE_SRC/" "$LOCAL_SHARE_DST/"

echo "==> Syncing bin..."
mkdir -p "$BIN_DST"
rsync -av --delete "$BIN_SRC/" "$BIN_DST/"

echo "==> Syncing zsh configs..."
mkdir -p "$ZSH_DST"
for file in .zshrc .p10k.zsh; do
  [ -f "$ZSH_SRC/$file" ] && cp -a "$ZSH_SRC/$file" "$ZSH_DST/$file"
done

echo "==> Syncing Pictures..."
if [ -d "$PICTURES_SRC" ]; then
  rm -rf "$PICTURES_DST"
  cp -a "$PICTURES_SRC" "$PICTURES_DST"
fi

echo "==> Done."
