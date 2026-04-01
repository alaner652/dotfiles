#!/bin/bash

# 定義 dotfiles 的絕對路徑
DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# 1. 確保系統是最新的並安裝基礎必要套件
echo "更新系統並安裝基礎套件..."
sudo pacman -Syu --noconfirm
sudo pacman -S --noconfirm base-devel git stow zsh \
    polkit-kde-agent xdg-desktop-portal-hyprland \
    kitty waybar wofi dunst neovim fastfetch

# 2. 安裝 yay (如果不存在)
if ! command -v yay &> /dev/null; then
    echo "安裝 yay..."
    rm -rf /tmp/yay-bin # 預防萬一，先清理殘骸
    git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
    cd /tmp/yay-bin && makepkg -si --noconfirm
    cd "$DOTFILES_DIR"
fi

# 3. 自動切換 Shell 為 Zsh
if [ "$SHELL" != "/usr/bin/zsh" ]; then
    echo "切換預設 Shell 為 Zsh..."
    # 這裡加上 sudo 確保在某些環境下能成功執行
    sudo chsh -s $(which zsh) $(whoami)
fi

# 4. 連結設定檔 (Config Files)
echo "正在連結 ~/.config 設定檔..."
# 確保目標目錄存在
mkdir -p ~/.config

cd "$DOTFILES_DIR/config"
for dir in */; do
    # 移除結尾斜線
    target=${dir%/}
    echo "Stowing: $target"
    stow -R -t ~/.config "$target"
done

# 5. 連結 Zsh 設定 (.zshrc)
echo "正在連結 Zsh 設定檔..."
cd "$DOTFILES_DIR/zsh"
stow -R -t ~ .

# 6. 連結腳本檔 (bin)
if [ -d "$DOTFILES_DIR/bin" ]; then
    echo "正在連結個人腳本..."
    mkdir -p ~/bin
    cd "$DOTFILES_DIR/bin"
    stow -R -t ~/bin .
fi

echo "--------------------------------------------------"
echo "✅ 連結完成！"
echo "💡 請按下 \$mainMod + M 重新啟動 Hyprland"
echo "💡 若 Zsh 主題未生效，請重新登入或輸入 'zsh'"
echo "--------------------------------------------------"