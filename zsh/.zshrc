# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

if [[ -r ~/.cache/p10k-instant-prompt-${TTY##*/}.zsh ]]; then
  source ~/.cache/p10k-instant-prompt-${TTY##*/}.zsh
fi

export ZSH="$HOME/.oh-my-zsh"
export ZSH_CUSTOM="${ZSH_CUSTOM:-$ZSH/custom}"
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
source "$ZSH_CUSTOM/themes/powerlevel10k/powerlevel10k.zsh-theme"

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

alias clear='printf "\033c"'
alias ff='fastfetch'
alias ls="ls --color=auto"
alias ll="ls -la"
