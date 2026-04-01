if [[ -r ~/.cache/p10k-instant-prompt-${TTY##*/}.zsh ]]; then
  source ~/.cache/p10k-instant-prompt-${TTY##*/}.zsh
fi

export ZSH="$HOME/.oh-my-zsh"
export LANG=zh_TW.UTF-8
export LC_ALL=zh_TW.UTF-8

# PATH
export PATH="$HOME/.local/bin:$PATH"

plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh
source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

alias clear='printf "\033c"'
alias ff='fastfetch'
alias ls="ls --color=auto"
alias ll="ls -la"
