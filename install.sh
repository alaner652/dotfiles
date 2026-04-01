#!/bin/bash

# --- [1] 定義絕對路徑 ---
DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "🚀 開始執行部署 (Austin's Hardcore Version)..."

# 1. 基礎套件與軟體安裝 (包含你提到的 Zen, Vesktop, OBS 等)
echo "📦 更新系統並安裝核心套件..."
sudo pacman -Syu --noconfirm
sudo pacman -S --noconfirm base-devel git zsh ttf-cascadia-code-nerd

# 安裝 yay
if ! command -v yay &> /dev/null; then
    echo "安裝 yay..."
    git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
    cd /tmp/yay-bin && makepkg -si --noconfirm
    cd "$DOTFILES_DIR"
fi

# 安裝指定軟體 (Vesktop = Vencord, Zen Browser, Hyprshot, OBS)
echo "🚀 安裝全套工具..."
yay -S --noconfirm \
    polkit-kde-agent xdg-desktop-portal-hyprland \
    kitty waybar wofi dunst neovim fastfetch \
    swaybg hyprpaper matugen-bin \
    vesktop zen-browser-bin pear-desktop-bin \
    hyprshot obs-studio

# --- [2] 核心對位邏輯：讓 .config 正常工作 ---
echo "🚚 正在處理 .config 對位..."

# 確保系統的 ~/.config 存在
mkdir -p "$HOME/.config"

# 直接進入你倉庫的 config 資料夾 (裡面是 hypr, kitty 等)
if [ -d "$DOTFILES_DIR/config" ]; then
    # 這裡用循環，確保每一個子資料夾都是「整包」對位
    for folder in "$DOTFILES_DIR/config/"*/; do
        target_name=$(basename "$folder")
        echo "   -> 映射: ~/.config/$target_name"
        
        # 徹底刪除系統原有的殘骸 (避開連結錯誤)
        rm -rf "$HOME/.config/$target_name"
        
        # 使用實體複製 (或 ln -sfn，這裡推薦複製以確保測試環境最穩)
        cp -arf "$folder" "$HOME/.config/"
    done
fi

# --- [3] 讓 bin 底下的腳本正常工作 ---
echo "🚚 正在處理 ~/bin 腳本對位..."

# 確保系統的 ~/bin 存在
mkdir -p "$HOME/bin"

if [ -d "$DOTFILES_DIR/bin" ]; then
    # 把倉庫 bin 裡面的內容通通搬過去
    cp -arf "$DOTFILES_DIR/bin/." "$HOME/bin/"
    # 強制賦予執行權限，確保腳本能跑
    chmod +x "$HOME/bin/"*
    echo "✅ 個人腳本已就位並賦予執行權限"
fi

# --- [4] 處理 Zsh 與 Pictures ---
echo "🚚 處理其餘設定..."
[ -f "$DOTFILES_DIR/zsh/.zshrc" ] && cp -af "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
[ -f "$DOTFILES_DIR/zsh/.p10k.zsh" ] && cp -af "$DOTFILES_DIR/zsh/.p10k.zsh" "$HOME/.p10k.zsh"

if [ -d "$DOTFILES_DIR/Pictures" ]; then
    rm -rf "$HOME/Pictures"
    cp -arf "$DOTFILES_DIR/Pictures" "$HOME/"
fi

# --- [5] 環境收尾 ---
sudo chown -R $(whoami):$(whoami) "$HOME"
[ "$SHELL" != "/usr/bin/zsh" ] && sudo chsh -s $(which zsh) $(whoami)

echo "--------------------------------------------------"
echo "✨ 部署完成！"
echo "📂 檢驗清單："
echo "   - .config: $(ls -d ~/.config/hypr 2>/dev/null || echo '❌ 失敗')"
echo "   - bin 腳本: $(ls ~/bin | head -n 1 2>/dev/null || echo '❌ 失敗')"
echo "💡 請按下 \$mainMod + M 重啟環境"
echo "--------------------------------------------------"