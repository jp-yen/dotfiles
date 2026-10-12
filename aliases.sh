#!/bin/sh
# /etc/profile.d/aliases.sh
# sh / bash / ash / zsh 共通エイリアス・環境変数設定

# 基本エイリアス
alias c='clear'
alias ..='cd ..'
alias ...='cd ../..'

# ls エイリアス
alias ls='ls -F --color=auto'
alias ll='ls -alF --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'

# screen
alias screen="/usr/bin/screen -U -D -RR"
export SCREENDIR="$HOME/.screen"
if [ ! -d "$SCREENDIR" ]; then
    mkdir -p "$SCREENDIR" && chmod 700 "$SCREENDIR"
fi

# vi / vim
command -v vim >/dev/null 2>&1 && alias vi='vim'

# ロケール変更用エイリアス
alias C='unset LANG LC_ALL'
alias JP='export LANG=ja_JP.UTF-8'

# less / PAGER 設定
if command -v less >/dev/null 2>&1; then
    alias less='less -X'
    export LESS='-ReFXsc'
    export PAGER='less'
    export SYSTEMD_LESS='RXK'

    # lesspipe 設定
    if command -v lesspipe >/dev/null 2>&1; then
        export LESSOPEN='| lesspipe %s'
    elif command -v lesspipe.sh >/dev/null 2>&1; then
        export LESSOPEN='| lesspipe.sh %s'
    fi
elif command -v more >/dev/null 2>&1; then
    export PAGER='more'
fi

# dircolors 設定
if command -v dircolors >/dev/null 2>&1; then
    [ -r ~/.dircolors ] && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi


