#!/usr/bin/env bash

IMG_ROOT="$HOME/.config/fastfetch"
PNG_DIR="$IMG_ROOT/pngs"

files=()

# PNG
if [ -d "$PNG_DIR" ]; then
    while IFS= read -r -d '' file; do
        files+=("$file")
    done < <(find "$PNG_DIR" -type f -print0 2>/dev/null)
fi

# 無檔案就不顯示
if [ ${#files[@]} -eq 0 ]; then
    echo ""
    exit 0
fi

# Pick 隨機
rand="${files[RANDOM % ${#files[@]}]}"
echo "$rand"

