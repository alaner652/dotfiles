# 在 install.sh 加入這段
if ! command -v yay &> /dev/null; then
    echo "安裝 yay..."
    git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
    cd /tmp/yay-bin && makepkg -si --noconfirm
fi

# 自動切換 Shell
if [ "$SHELL" != "/usr/bin/zsh" ]; then
    echo "切換預設 Shell 為 Zsh..."
    chsh -s $(which zsh)
fi
