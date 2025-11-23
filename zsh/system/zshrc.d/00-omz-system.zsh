# Bash用プロンプト変数をクリア（Bashからの移行対策）
unset PS1 PROMPT_COMMAND PROMPT_START PROMPT_HIGHLIGHT PROMPT_COLOR PROMPT_CONTAINER
unset PROMPT_USERHOST PROMPT_SEPARATOR PROMPT_SEPARATOR_COLOR PROMPT_DIRECTORY
unset PROMPT_GIT_BRANCH PROMPT_GIT_COLOR PROMPT_END PROMPT_DIR_COLOR PROMPT_DIRTRIM PROMPT_MARKER

# システム全体のOh My Zsh設定
export ZSH="/usr/share/oh-my-zsh"
export ZSH_CUSTOM="$ZSH/custom"

if [ ! -f "$ZSH/oh-my-zsh.sh" ]; then
    echo "警告: Oh My Zshが $ZSH に見つかりません"
    return
fi

export ZDOTDIR="${ZDOTDIR:-$HOME}"
export ZSH_CACHE_DIR="$HOME/.zsh/cache"
export ZSH_COMPDUMP="$HOME/.zsh/cache/.zcompdump-${HOST}-${ZSH_VERSION}"

[[ -d "$ZSH_CACHE_DIR" ]] || mkdir -p "$ZSH_CACHE_DIR"

ZSH_THEME="powerlevel10k/powerlevel10k"

# 基本プラグイン
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-completions
    fzf-tab
    sudo
    history
    colored-man-pages
    docker
    docker-compose
    kubectl
)

# OS判定と追加プラグイン
if [ -f /etc/os-release ]; then
    . /etc/os-release
    case "$ID" in
        fedora|rhel|centos|rocky|almalinux)
            plugins+=(dnf)
            ;;
        debian|ubuntu|linuxmint)
            plugins+=(debian)
            ;;
        # alpineは固有プラグインなし
    esac
    # ID_LIKEのチェック（IDでマッチしなかった場合）
    if [[ "$ID" != "fedora" && "$ID" != "rhel" && "$ID" != "centos" && "$ID" != "rocky" && "$ID" != "almalinux" && "$ID" != "debian" && "$ID" != "ubuntu" && "$ID" != "linuxmint" ]]; then
        if [[ "$ID_LIKE" == *"rhel"* || "$ID_LIKE" == *"fedora"* ]]; then
            plugins+=(dnf)
        elif [[ "$ID_LIKE" == *"debian"* ]]; then
            plugins+=(debian)
        fi
    fi
fi

plugins+=(systemd)

source $ZSH/oh-my-zsh.sh

if [[ -r "$ZSH_CACHE_DIR/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "$ZSH_CACHE_DIR/p10k-instant-prompt-${(%):-%n}.zsh"
fi

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
