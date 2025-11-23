#!/bin/bash

# エラー時に停止
set -e

echo "=========================================="
echo "  Oh My Zsh 統合セットアップスクリプト"
echo "=========================================="
echo ""

# ディストリビューション判定
detect_distribution() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO_ID="$ID"
        DISTRO_VERSION="$VERSION_ID"
        DISTRO_NAME="$NAME"
        
        # ID_LIKE を確認してファミリーを判定
        case "$ID" in
            fedora|rhel|centos|rocky|almalinux)
                DISTRO_FAMILY="redhat"
                PKG_MANAGER="dnf"
                ;;
            debian|ubuntu|linuxmint)
                DISTRO_FAMILY="debian"
                PKG_MANAGER="apt"
                ;;
            alpine)
                DISTRO_FAMILY="alpine"
                PKG_MANAGER="apk"
                ;;
            *)
                # ID_LIKE をチェック
                if echo "$ID_LIKE" | grep -q "rhel\|fedora"; then
                    DISTRO_FAMILY="redhat"
                    PKG_MANAGER="dnf"
                elif echo "$ID_LIKE" | grep -q "debian"; then
                    DISTRO_FAMILY="debian"
                    PKG_MANAGER="apt"
                else
                    echo "エラー: サポートされていないディストリビューションです: $ID"
                    exit 1
                fi
                ;;
        esac
    else
        echo "エラー: /etc/os-release が見つかりません"
        exit 1
    fi
    
    echo "検出されたディストリビューション: $DISTRO_NAME ($DISTRO_ID)"
    echo "ディストリビューションファミリー: $DISTRO_FAMILY"
    echo "パッケージマネージャー: $PKG_MANAGER"
    echo ""
}

# パッケージインストール
install_packages() {
    echo "必要なパッケージをインストールしています..."
    
    case "$PKG_MANAGER" in
        dnf)
            dnf install -y zsh git curl fzf util-linux-user
            ;;
        apt)
            apt update
            apt install -y zsh git curl fzf
            ;;
        apk)
            apk add --no-cache zsh git curl fzf shadow sudo
            ;;
    esac
    
    echo "✓ パッケージのインストールが完了しました"
    echo ""
}

# Oh My Zshのインストール
install_oh_my_zsh() {
    local ZSH_DIR="/usr/share/oh-my-zsh"
    
    if [ -d "$ZSH_DIR" ]; then
        echo "Oh My Zshは既にインストールされています: $ZSH_DIR"
    else
        echo "Oh My Zshをシステム全体にインストールしています..."
        git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$ZSH_DIR"
        echo "✓ Oh My Zshのインストールが完了しました"
    fi
    echo ""
}

# プラグインのインストール
install_plugins() {
    local ZSH_CUSTOM="/usr/share/oh-my-zsh/custom"
    
    echo "Oh My Zshプラグインをインストールしています..."
    
    # zsh-autosuggestions
    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
        git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
        echo "✓ zsh-autosuggestions をインストールしました"
    else
        echo "  zsh-autosuggestions は既にインストールされています"
    fi
    
    # zsh-syntax-highlighting
    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
        git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
        echo "✓ zsh-syntax-highlighting をインストールしました"
    else
        echo "  zsh-syntax-highlighting は既にインストールされています"
    fi
    
    # zsh-completions
    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-completions" ]; then
        git clone --depth=1 https://github.com/zsh-users/zsh-completions "$ZSH_CUSTOM/plugins/zsh-completions"
        echo "✓ zsh-completions をインストールしました"
    else
        echo "  zsh-completions は既にインストールされています"
    fi
    
    # fzf-tab
    if [ ! -d "$ZSH_CUSTOM/plugins/fzf-tab" ]; then
        git clone --depth=1 https://github.com/Aloxaf/fzf-tab "$ZSH_CUSTOM/plugins/fzf-tab"
        echo "✓ fzf-tab をインストールしました"
    else
        echo "  fzf-tab は既にインストールされています"
    fi
    
    echo "✓ プラグインのインストールが完了しました"
    echo ""
}

# Powerlevel10kテーマのインストール
install_powerlevel10k() {
    local ZSH_CUSTOM="/usr/share/oh-my-zsh/custom"
    local P10K_DIR="$ZSH_CUSTOM/themes/powerlevel10k"
    
    if [ ! -d "$P10K_DIR" ]; then
        echo "Powerlevel10kテーマをインストールしています..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
        echo "✓ Powerlevel10kのインストールが完了しました"
    else
        echo "Powerlevel10kは既にインストールされています"
    fi
    echo ""
}

# ディストリビューション固有の設定
setup_distro_specific() {
    case "$DISTRO_FAMILY" in
        redhat)
            DISTRO_ALIASES="alias update='sudo dnf update'
alias install='sudo dnf install'
alias remove='sudo dnf remove'
alias search='dnf search'"
            DISTRO_PLUGIN="dnf"
            ;;
        debian)
            DISTRO_ALIASES="alias update='sudo apt update && sudo apt upgrade'
alias install='sudo apt install'
alias remove='sudo apt remove'
alias search='apt search'"
            DISTRO_PLUGIN="debian"
            ;;
        alpine)
            DISTRO_ALIASES="alias update='sudo apk update && sudo apk upgrade'
alias install='sudo apk add'
alias remove='sudo apk del'
alias search='apk search'"
            DISTRO_PLUGIN=""
            ;;
    esac
}

# fzfパスの設定
setup_fzf_paths() {
    case "$DISTRO_FAMILY" in
        redhat)
            FZF_PATHS='[ -f /usr/share/fzf/shell/key-bindings.zsh ] && source /usr/share/fzf/shell/key-bindings.zsh'
            ;;
        debian)
            FZF_PATHS='[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ] && source /usr/share/doc/fzf/examples/key-bindings.zsh
[ -f /usr/share/doc/fzf/examples/completion.zsh ] && source /usr/share/doc/fzf/examples/completion.zsh'
            ;;
        alpine)
            FZF_PATHS='[ -f /usr/share/fzf/key-bindings.zsh ] && source /usr/share/fzf/key-bindings.zsh
[ -f /usr/share/fzf/completion.zsh ] && source /usr/share/fzf/completion.zsh'
            ;;
    esac
}

# システム設定ファイル作成関数
create_system_config() {
    # 設定パスを定義
    CONFIG_DIR="/etc/zsh/zshrc.d"
    OMZ_CONFIG="$CONFIG_DIR/00-omz-system.zsh"
    DEFAULTS_CONFIG="$CONFIG_DIR/01-defaults.zsh"
    
    config_dir="$CONFIG_DIR"
    omz_config="$OMZ_CONFIG"
    defaults_config="$DEFAULTS_CONFIG"

    # Oh My Zsh完全初期化を生成する関数
    generate_omz_config() {
        cat << 'OMZ_CONFIG_EOF'
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
OMZ_CONFIG_EOF
        # ディストリビューション固有のプラグインを追加
        [ -n "$DISTRO_PLUGIN" ] && echo "    $DISTRO_PLUGIN"
        
        cat << 'OMZ_CONFIG_EOF2'
    systemd
)

source $ZSH/oh-my-zsh.sh

if [[ -r "$ZSH_CACHE_DIR/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "$ZSH_CACHE_DIR/p10k-instant-prompt-${(%):-%n}.zsh"
fi

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
OMZ_CONFIG_EOF2
    }

    # デフォルト設定全体を生成する関数
    generate_defaults_config() {
        cat << 'DEFAULTS_EOF'
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

DEFAULTS_EOF
        # ディストリビューション固有のエイリアスを追加
        echo "# ディストリビューション固有のエイリアス"
        echo "$DISTRO_ALIASES"
        echo ""
        
        cat << DEFAULTS_EOF2
export HISTFILE="\$HOME/.zsh/history"
HISTSIZE=10000
SAVEHIST=10000

[[ -d "\$HOME/.zsh" ]] || mkdir -p "\$HOME/.zsh"

export SCREENDIR="\$HOME/.screen"
[[ -d "\$SCREENDIR" ]] || mkdir -p "\$SCREENDIR"

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

# fzf設定
$FZF_PATHS

if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "\$(dircolors -b ~/.dircolors)" || eval "\$(dircolors -b)"
fi
DEFAULTS_EOF2
    }

    # 設定生成処理（/etc/zsh/zshrc.d/ を使用）
    mkdir -p "$config_dir"
    
    generate_omz_config > "$omz_config"
    generate_defaults_config > "$defaults_config"
    
    chmod 644 "$config_dir"/*.zsh

    # ディストリビューション固有の設定を実行
    if [ "$PKG_MANAGER" = "dnf" ]; then
        configure_fedora_zshrc
    elif [ "$PKG_MANAGER" = "apt" ]; then
        configure_zshrc_loader
    elif [ "$PKG_MANAGER" = "apk" ]; then
        configure_zshrc_loader
    fi
}

# Fedora固有の設定
configure_fedora_zshrc() {
    echo "Fedora固有の設定を適用しています..."
    # 追加の設定があればここに記述
}

# /etc/zsh/zshrc ローダーの設定（Debian/Alpine用）
configure_zshrc_loader() {
    echo "/etc/zsh/zshrc ローダーを設定しています..."
    # /etc/zsh/zshrc の設定
    # 既存の設定があるか確認
    if [ -f /etc/zsh/zshrc ] && grep -q "/etc/zsh/zshrc.d" /etc/zsh/zshrc; then
        echo "  /etc/zsh/zshrc は既に設定済みです"
    else
        # 追記または新規作成
        cat >> /etc/zsh/zshrc << 'EOF'

# /etc/zsh/zshrc.d/ 内のファイルを読み込む
if [ -d /etc/zsh/zshrc.d ]; then
    for file in /etc/zsh/zshrc.d/*.zsh; do
        [ -r "$file" ] && source "$file"
    done
    unset file
fi
EOF
        chmod 644 /etc/zsh/zshrc
        echo "✓ /etc/zsh/zshrc を更新しました"
    fi
}

# ヘルパー関数のインストール
install_helper_functions() {
    local HELPER_SCRIPT="/usr/local/bin/setup-my-zsh"
    
    cat > "$HELPER_SCRIPT" << 'HELPER_EOF'
#!/bin/bash

# ユーザー用Oh My Zshセットアップヘルパー

USER_HOME="$HOME"
ZSH_DIR="$USER_HOME/.zsh"
ZSH_CACHE_DIR="$USER_HOME/.zsh/cache"
SCREEN_DIR="$USER_HOME/.screen"

# Oh My Zshがインストールされているか確認
if [ ! -f /usr/share/oh-my-zsh/oh-my-zsh.sh ]; then
    echo "エラー: Oh My Zshがシステムにインストールされていません"
    echo "管理者にシステムセットアップスクリプトを実行してもらってください"
    exit 1
fi

echo "=========================================="
echo "  個人用Oh My Zsh設定"
echo "=========================================="
echo ""

# .zshディレクトリとキャッシュの作成
echo "~/.zsh ディレクトリ構造を作成しています..."
mkdir -p "$ZSH_DIR"
mkdir -p "$ZSH_CACHE_DIR"

echo "~/.screen ディレクトリを作成しています..."
mkdir -p "$SCREEN_DIR"
chmod 700 "$SCREEN_DIR"

# 既存のzshファイルを移動
echo "既存のzshファイルを ~/.zsh/ へ移動しています..."

# .zsh_historyの移動
if [ -f "$USER_HOME/.zsh_history" ]; then
    mv -f "$USER_HOME/.zsh_history" "$ZSH_DIR/history" 2>/dev/null && \
        echo "  ✓ .zsh_history を ~/.zsh/history へ移動しました" || true
fi

# .zcompdumpファイルの移動
for zcomp in "$USER_HOME"/.zcompdump*; do
    if [ -f "$zcomp" ]; then
        mv -f "$zcomp" "$ZSH_CACHE_DIR/" 2>/dev/null && \
            echo "  ✓ $(basename "$zcomp") を移動しました" || true
    fi
done

# p10k instant promptキャッシュの移動
if [ -d "$USER_HOME/.cache" ]; then
    for cache_file in "$USER_HOME/.cache"/p10k-*; do
        if [ -f "$cache_file" ]; then
            mv -f "$cache_file" "$ZSH_CACHE_DIR/" 2>/dev/null && \
                echo "  ✓ $(basename "$cache_file") を移動しました" || true
        fi
    done
fi

echo ""

# .zshrcの作成
if [ ! -f "$USER_HOME/.zshrc" ]; then
    cat > "$USER_HOME/.zshrc" << 'ZSHRC_EOF'
# Powerlevel10kのインスタントプロンプトを有効化。~/.zshrcの先頭付近に配置する必要があります。
if [[ -r "${XDG_CACHE_HOME:-$HOME/.zsh/cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.zsh/cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# プロンプトをカスタマイズするには、p10k configure を実行するか ~/.p10k.zsh を編集してください。
if [[ -f ~/.p10k.zsh ]]; then
  source ~/.p10k.zsh
  # カスタム設定（.p10k.zsh読み込み後）
  [[ ! -f ~/.p10k-post.zsh ]] || source ~/.p10k-post.zsh
fi

# カスタム関数の読み込み
[[ -f ~/.zsh/functions.zsh ]] && source ~/.zsh/functions.zsh
ZSHRC_EOF
    echo "✓ .zshrc を作成しました"
    echo ""
else
    echo "警告: ~/.zshrc は既に存在するため、作成をスキップしました"
    echo "      既存の設定は変更されていません"
    echo ""
fi

# キャッシュクリア関数の追加
cat > "$ZSH_DIR/functions.zsh" << 'FUNC_EOF'
# Zshキャッシュクリア関数
clean-zsh-cache() {
    rm -rf ~/.zsh/cache/*
    rm -f ~/.zcompdump*
    echo "✓ Zshキャッシュをクリアしました"
    echo "  変更を反映するには 'exec zsh' を実行してください"
}
FUNC_EOF

# .p10k-post.zsh作成（.p10k.zshの後に自動読み込み）
cat > "$USER_HOME/.p10k-post.zsh" << 'P10K_POST_EOF'
# .p10k-post.zsh
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(os_icon host dir vcs newline prompt_char)

if [[ $UID == 0 ]]; then
  typeset -g POWERLEVEL9K_HOST_FOREGROUND=1
  typeset -g POWERLEVEL9K_HOST_BACKGROUND=0
  typeset -g POWERLEVEL9K_HOST_TEMPLATE='%n🚨%m'
  typeset -g POWERLEVEL9K_HOST_VISUAL_IDENTIFIER_EXPANSION='🚨'
else
  typeset -g POWERLEVEL9K_HOST_FOREGROUND=51
  typeset -g POWERLEVEL9K_HOST_BACKGROUND=30
  typeset -g POWERLEVEL9K_HOST_TEMPLATE='%n 💻 %m'
  typeset -g POWERLEVEL9K_HOST_VISUAL_IDENTIFIER_EXPANSION='🐳'
fi

P10K_POST_EOF

echo "✓ .p10k-post.zsh を作成しました（カスタム設定）"
echo ""

echo "======================================"
echo "  セットアップが完了しました！"
echo "======================================"
echo ""

if [ ! -f "$USER_HOME/.p10k.zsh" ]; then
    echo "次のステップ:"
    echo "1. 'zsh' でzshを起動"
    echo "2. 初回起動時にPowerlevel10k設定ウィザードが自動的に開始されます"
    echo "3. 設定後は以下を実行してカスタム設定を適用:"
    echo "   source ~/.p10k-post.zsh && p10k reload"
    echo "   または 'exec zsh' で再起動"
else
    echo "zshを再起動してください:"
    echo "  exec zsh"
fi

echo "デフォルトシェルをzshに変更する場合:"
echo "  chsh -s \$(which zsh)"
echo ""
echo "便利なコマンド:"
echo "  p10k configure  - プロンプトを再設定"
echo "  clean-zsh-cache - キャッシュをクリア"
echo ""
HELPER_EOF

    chmod +x "$HELPER_SCRIPT"
    echo "✓ ヘルパースクリプトをインストールしました: $HELPER_SCRIPT"
    echo ""

    # 共有コンポーネント更新スクリプトのインストール
    local UPDATE_SCRIPT="/usr/local/bin/update-zsh-shared"
    cat > "$UPDATE_SCRIPT" << 'UPDATE_EOF'
#!/bin/bash
set -e

if [ "$EUID" -ne 0 ]; then
    echo "エラー: このスクリプトはroot権限で実行する必要があります"
    echo "sudo $0 を使用してください"
    exit 1
fi

echo "Oh My Zsh本体を更新しています..."
git -C /usr/share/oh-my-zsh pull || echo "  更新に失敗しました"

echo "プラグインとテーマを更新しています..."
find /usr/share/oh-my-zsh/custom -maxdepth 2 -type d -name ".git" | while read gitdir; do
    dir=$(dirname "$gitdir")
    echo "  $(basename "$dir") を更新中..."
    git -C "$dir" pull || echo "    更新に失敗しました"
done

echo "✓ 更新が完了しました"
UPDATE_EOF

    chmod +x "$UPDATE_SCRIPT"
    echo "✓ 更新スクリプトをインストールしました: $UPDATE_SCRIPT"
    echo ""
}

# メイン処理
main() {
    # root権限チェック
    if [ "$EUID" -ne 0 ]; then
        echo "エラー: このスクリプトはroot権限で実行する必要があります"
        echo "sudo $0 を使用してください"
        exit 1
    fi
    
    # ディストリビューション判定
    detect_distribution
    
    # ディストリビューション固有の設定
    setup_distro_specific
    
    # fzfパスの設定
    setup_fzf_paths
    
    # パッケージインストール
    install_packages
    
    # Oh My Zshインストール
    install_oh_my_zsh
    
    # プラグインインストール
    install_plugins
    
    # Powerlevel10kインストール
    install_powerlevel10k
    
    # システム設定ファイル作成
    echo "システム設定ファイルを作成しています..."
    create_system_config
    echo "✓ システム設定ファイルの作成が完了しました"
    echo ""
    
    # ヘルパー関数のインストール
    install_helper_functions
    
    echo "=========================================="
    echo "  システムセットアップ完了！"
    echo "=========================================="
    echo ""
    echo "利用したいユーザーは、以下を実行してください:"
    echo "  setup-my-zsh"
    echo "  ※ zshを起動せずに実行してください"
    echo ""
    echo "その後、zshを起動して初期設定を行ってください:"
    echo "  exec zsh"
    echo ""
}

# スクリプト実行
main
