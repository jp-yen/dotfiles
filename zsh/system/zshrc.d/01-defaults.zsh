# デフォルトエイリアス
alias ll='ls -alF --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'
alias ..='cd ..'
alias ...='cd ../..'
alias c='clear'

(( $+commands[vim] )) && alias vi='vim'

# less設定
if (( $+commands[less] )); then
    alias less='less -X'
    export LESS='-ReFXsc'
    export PAGER='less'
    export SYSTEMD_LESS='RXK'

    # lesspipe configuration
    if (( $+commands[lesspipe] )); then
        export LESSOPEN='| lesspipe %s'
    elif (( $+commands[lesspipe.sh] )); then
        export LESSOPEN='| lesspipe.sh %s'
    fi
elif (( $+commands[more] )); then
    export PAGER='more'
fi

# LESS_TERMCAP settings (man page colors)
if command -v tput >/dev/null 2>&1; then
    export LESS_TERMCAP_mb=$(tput blink)
    export LESS_TERMCAP_md=$(tput bold)
    export LESS_TERMCAP_so=$(tput smso)
    export LESS_TERMCAP_se=$(tput rmso)
    export LESS_TERMCAP_us=$(tput smul; tput setab 4)
    export LESS_TERMCAP_ue=$(tput rmul; tput op)
    export LESS_TERMCAP_me=$(tput sgr0)
    export LESS_TERMCAP_zz=$(tput sgr0)

    if [[ $(tput colors) -gt 254 ]]; then
        export LESS_TERMCAP_md=$(tput bold; tput setab 237)
        export LESS_TERMCAP_so=$(tput smso; tput setab 18; tput setaf 229)
        export LESS_TERMCAP_se=$(tput rmso; tput op)
        export LESS_TERMCAP_us=$(tput smul; tput setab 4; tput setaf 136)
    fi
else
    export LESS_TERMCAP_md=$'\e[1;44m'
    export LESS_TERMCAP_mb=$'\e[1;5;31m'
    export LESS_TERMCAP_me=$'\e[0m'
    export LESS_TERMCAP_so=$'\e[5;7;229m'
    export LESS_TERMCAP_se=$'\e[0m'
    export LESS_TERMCAP_us=$'\e[4m'
    export LESS_TERMCAP_ue=$'\e[24m'
    export LESS_TERMCAP_zz=$'\e[0m'
fi

# ロケール変更用エイリアス
alias C='export LANG=C'
alias JP='export LANG=ja_JP.UTF-8'

# ディストリビューション固有のエイリアスと設定
if [ -f /etc/os-release ]; then
    . /etc/os-release
    
    # ファミリー判定
    DISTRO_FAMILY=""
    case "$ID" in
        fedora|rhel|centos|rocky|almalinux)
            DISTRO_FAMILY="redhat"
            ;;
        debian|ubuntu|linuxmint)
            DISTRO_FAMILY="debian"
            ;;
        alpine)
            DISTRO_FAMILY="alpine"
            ;;
        *)
            if [[ "$ID_LIKE" == *"rhel"* || "$ID_LIKE" == *"fedora"* ]]; then
                DISTRO_FAMILY="redhat"
            elif [[ "$ID_LIKE" == *"debian"* ]]; then
                DISTRO_FAMILY="debian"
            fi
            ;;
    esac

    # エイリアス設定
    case "$DISTRO_FAMILY" in
        redhat)
            alias update='sudo dnf update'
            alias install='sudo dnf install'
            alias remove='sudo dnf remove'
            alias search='dnf search'
            ;;
        debian)
            alias update='sudo apt update && sudo apt upgrade'
            alias install='sudo apt install'
            alias remove='sudo apt remove'
            alias search='apt search'
            ;;
        alpine)
            alias update='sudo apk update && sudo apk upgrade'
            alias install='sudo apk add'
            alias remove='sudo apk del'
            alias search='apk search'
            ;;
    esac

    # fzfパス設定
    case "$DISTRO_FAMILY" in
        redhat)
            [ -f /usr/share/fzf/shell/key-bindings.zsh ] && source /usr/share/fzf/shell/key-bindings.zsh
            ;;
        debian)
            [ -f /usr/share/doc/fzf/examples/key-bindings.zsh ] && source /usr/share/doc/fzf/examples/key-bindings.zsh
            [ -f /usr/share/doc/fzf/examples/completion.zsh ] && source /usr/share/doc/fzf/examples/completion.zsh
            ;;
        alpine)
            [ -f /usr/share/fzf/key-bindings.zsh ] && source /usr/share/fzf/key-bindings.zsh
            [ -f /usr/share/fzf/completion.zsh ] && source /usr/share/fzf/completion.zsh
            ;;
    esac
fi

export HISTFILE="$HOME/.zsh/history"
HISTSIZE=10000
SAVEHIST=10000

[[ -d "$HOME/.zsh" ]] || mkdir -p "$HOME/.zsh"

export SCREENDIR="$HOME/.screen"
if [[ ! -d "$SCREENDIR" ]]; then
    mkdir -p "$SCREENDIR"
    chmod 700 "$SCREENDIR"
fi

# パスの重複削除
typeset -U path

setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY
setopt INC_APPEND_HISTORY

autoload -U history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end

bindkey '^P' history-beginning-search-backward-end
bindkey '^N' history-beginning-search-forward-end
bindkey '^[[A' history-beginning-search-backward-end
bindkey '^[[B' history-beginning-search-forward-end

if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi
