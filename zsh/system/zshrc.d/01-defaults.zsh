# 共通エイリアス・環境変数 (/etc/profile.d/aliases.sh) の読み込み
[[ -r /etc/profile.d/aliases.sh ]] && source /etc/profile.d/aliases.sh

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

# ディストリビューション固有の fzf パス設定
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
