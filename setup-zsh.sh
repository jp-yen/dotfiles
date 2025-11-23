#!/bin/bash

# エラー時に停止
set -e

echo "=========================================="
echo "  Oh My Zsh 統合セットアップスクリプト"
echo "=========================================="

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
            dnf install -y zsh git curl fzf
            ;;
        apt)
            apt update
            apt install -y zsh git curl fzf
            ;;
        apk)
            apk add --no-cache zsh git curl fzf
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

# Fedora固有の設定
configure_fedora_zshrc() {
    echo "Fedora固有の設定を適用しています..."
    
    # /etc/zshrc の設定
    if [ -f /etc/zshrc ] && grep -q "/etc/zsh/zshrc.d" /etc/zshrc; then
        echo "  /etc/zshrc は既に設定済みです"
    else
        # 追記
        cat >> /etc/zshrc << 'EOF'

# /etc/zsh/zshrc.d/ 内のファイルを読み込む
if [ -d /etc/zsh/zshrc.d ]; then
    for file in /etc/zsh/zshrc.d/*.zsh; do
        [ -r "$file" ] && source "$file"
    done
    unset file
fi
EOF
        echo "✓ /etc/zshrc を更新しました"
    fi
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

# システム設定ファイル作成関数
create_system_config() {
    # 設定パスを定義
    CONFIG_DIR="/etc/zsh/zshrc.d"
    SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/zsh/system/zshrc.d"
    
    echo "システム設定ファイルを作成しています..."
    
    if [ ! -d "$SOURCE_DIR" ]; then
        echo "エラー: 設定ファイルディレクトリが見つかりません: $SOURCE_DIR"
        exit 1
    fi

    mkdir -p "$CONFIG_DIR"
    
    # ファイルをコピー
    cp -f "$SOURCE_DIR"/*.zsh "$CONFIG_DIR/"
    chmod 644 "$CONFIG_DIR"/*.zsh
    
    echo "✓ 設定ファイルをコピーしました: $CONFIG_DIR"

    # ディストリビューション固有の設定を実行
    if [ "$PKG_MANAGER" = "dnf" ]; then
        configure_fedora_zshrc
    elif [ "$PKG_MANAGER" = "apt" ]; then
        configure_zshrc_loader
    elif [ "$PKG_MANAGER" = "apk" ]; then
        configure_zshrc_loader
    fi
    
    echo "✓ システム設定ファイルの作成が完了しました"
    echo ""
}

# SSH Agent 初期化スクリプトのインストール
install_ssh_agent_script() {
    local SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local SSH_AGENT_SETUP="$SCRIPT_DIR/ssh-agent-setup.sh"
    
    if [ -f "$SSH_AGENT_SETUP" ]; then
        echo "SSH Agent 初期化スクリプトをインストールしています..."
        bash "$SSH_AGENT_SETUP"
        echo ""
    else
        echo "警告: ssh-agent-setup.sh が見つかりません"
        echo "      $SSH_AGENT_SETUP"
        echo "      SSH Agent 自動起動の設定をスキップします"
        echo ""
    fi
}

# ヘルパー関数のインストール
install_helper_functions() {
    local HELPER_SCRIPT="/usr/local/bin/setup-my-zsh"
    local UPDATE_SCRIPT="/usr/local/bin/update-zsh-shared"
    local SOURCE_BIN="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/zsh/bin"
    
    if [ ! -d "$SOURCE_BIN" ]; then
        echo "エラー: バイナリディレクトリが見つかりません: $SOURCE_BIN"
        exit 1
    fi
    
    cp -f "$SOURCE_BIN/setup-my-zsh" "$HELPER_SCRIPT"
    chmod +x "$HELPER_SCRIPT"
    echo "✓ ヘルパースクリプトをインストールしました: $HELPER_SCRIPT"
    
    cp -f "$SOURCE_BIN/update-zsh-shared" "$UPDATE_SCRIPT"
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
    
    # パッケージインストール
    install_packages
    
    # Oh My Zshインストール
    install_oh_my_zsh
    
    # プラグインインストール
    install_plugins
    
    # Powerlevel10kインストール
    install_powerlevel10k
    
    # システム設定ファイル作成
    create_system_config
    
    # SSH Agent 初期化スクリプトのインストール
    install_ssh_agent_script
    
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
echo ""
