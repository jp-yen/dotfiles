#!/bin/bash
# SSH Agent Setup Script with Auto-configuration

# スクリプト本体
SSH_AGENT_SCRIPT='#!/bin/sh

# 保存先ファイル
AGENT_SH="$HOME/.ssh-agent.sh"
AGENT_CSH="$HOME/.ssh-agent.csh"

# 二重実行防止
if [ -n "$SSH_AGENT_INIT_DONE" ]; then
    return
fi
export SSH_AGENT_INIT_DONE=1

# sh形式の環境変数を読み込む
if [ -f "$AGENT_SH" ]; then
    . "$AGENT_SH" >/dev/null 2>&1
fi

# ssh-agent が生きているか確認
if [ -z "$SSH_AGENT_PID" ] || ! kill -0 "$SSH_AGENT_PID" 2>/dev/null; then
    echo "Starting new ssh-agent..."
    # ssh-agent を起動し、sh形式で保存
    ssh-agent -s > "$AGENT_SH"
    . "$AGENT_SH"
    # sh形式から csh形式に変換
    awk -F'"'"'[=;]'"'"' '"'"'/^SSH_/ { print "setenv " $1 " " $2 ";" }'"'"' "$AGENT_SH" > "$AGENT_CSH"
fi

# 鍵が登録されていなければメッセージを表示
if ! ssh-add -l >/dev/null 2>&1; then
    echo ""
    echo "SSH鍵が登録されていません。"
    echo "以下のコマンドでSSH鍵を生成してください："
    echo ""
    echo "  ssh-keygen -t ed25519 -C \"your_email@example.com\""
    echo ""
    echo "詳細は https://github.com/jp-yen/dotfiles/blob/main/ssh-agent.md を参照してください。"
    echo ""
fi
'

# rootで実行されているか確認
if [ "$(id -u)" -eq 0 ]; then
    echo "Running as root. Installing system-wide configuration..."

    # /etc/ssh-agent-init.sh として保存
    echo "$SSH_AGENT_SCRIPT" > /etc/ssh-agent-init.sh
    chmod 755 /etc/ssh-agent-init.sh
    echo "✓ Created /etc/ssh-agent-init.sh"

    # /etc/profile.d/ にログイン時の自動実行スクリプトを配置
    cat > /etc/profile.d/ssh-agent-init.sh << 'PROFILE_EOF'
# SSH Agent Initialization
if [ -f /etc/ssh-agent-init.sh ]; then
    . /etc/ssh-agent-init.sh
fi
PROFILE_EOF
    chmod 644 /etc/profile.d/ssh-agent-init.sh
    echo "✓ Created /etc/profile.d/ssh-agent-init.sh"

    # zshユーザー向けに /etc/zsh/zprofile にも追加
    if [ -d /etc/zsh ]; then
        if ! grep -q "ssh-agent-init.sh" /etc/zsh/zprofile 2>/dev/null; then
            cat >> /etc/zsh/zprofile << 'ZSH_EOF'

# SSH Agent Initialization
if [ -f /etc/ssh-agent-init.sh ]; then
    . /etc/ssh-agent-init.sh
fi
ZSH_EOF
            echo "✓ Added to /etc/zsh/zprofile"
        else
            echo "✓ /etc/zsh/zprofile already configured"
        fi
    fi

    # csh/tcsh ユーザー向け
    if [ -d /etc/csh/login.d ]; then
        cat > /etc/csh/login.d/ssh-agent-init.csh << 'CSH_EOF'
# SSH Agent Initialization for csh/tcsh
if ( -f /etc/ssh-agent-init.sh ) then
    sh /etc/ssh-agent-init.sh
    if ( -f "$HOME/.ssh-agent.csh" ) source "$HOME/.ssh-agent.csh"
endif
CSH_EOF
        chmod 644 /etc/csh/login.d/ssh-agent-init.csh
        echo "✓ Created /etc/csh/login.d/ssh-agent-init.csh"
    fi

    echo ""
    echo "======================================"
    echo "System-wide installation complete!"
    echo "======================================"
    echo ""
    echo "Configuration files created:"
    echo "  • /etc/ssh-agent-init.sh (main script)"
    echo "  • /etc/profile.d/ssh-agent-init.sh (bash/sh auto-load)"
    if [ -f /etc/zsh/zprofile ]; then
        echo "  • /etc/zsh/zprofile (zsh auto-load)"
    fi
    if [ -f /etc/csh/login.d/ssh-agent-init.csh ]; then
        echo "  • /etc/csh/login.d/ssh-agent-init.csh (csh/tcsh auto-load)"
    fi
    echo ""
    echo "All users will automatically initialize ssh-agent on login."
    echo "To test immediately, run: source /etc/ssh-agent-init.sh"
    echo ""

else
    echo "Running as regular user. Installing for current user only..."

    # ユーザーのホームディレクトリに保存
    USER_SCRIPT="$HOME/.ssh-agent-init.sh"
    echo "$SSH_AGENT_SCRIPT" > "$USER_SCRIPT"
    chmod 755 "$USER_SCRIPT"
    echo "✓ Created $USER_SCRIPT"

    # .bashrc に追加
    if [ -f "$HOME/.bashrc" ]; then
        if ! grep -q ".ssh-agent-init.sh" "$HOME/.bashrc" 2>/dev/null; then
            cat >> "$HOME/.bashrc" << 'BASH_EOF'

# SSH Agent Initialization
if [ -f "$HOME/.ssh-agent-init.sh" ]; then
    . "$HOME/.ssh-agent-init.sh"
fi
BASH_EOF
            echo "✓ Added to ~/.bashrc"
        else
            echo "✓ ~/.bashrc already configured"
        fi
    fi

    # .zshrc に追加
    if [ -f "$HOME/.zshrc" ]; then
        if ! grep -q ".ssh-agent-init.sh" "$HOME/.zshrc" 2>/dev/null; then
            cat >> "$HOME/.zshrc" << 'ZSH_EOF'

# SSH Agent Initialization
if [ -f "$HOME/.ssh-agent-init.sh" ]; then
    . "$HOME/.ssh-agent-init.sh"
fi
ZSH_EOF
            echo "✓ Added to ~/.zshrc"
        else
            echo "✓ ~/.zshrc already configured"
        fi
    fi

    # .profile に追加（bashもzshもない場合のフォールバック）
    # sh/ash ユーザーのために常に設定するが、bash/zsh から読み込まれた場合は二重実行を防ぐためにスキップする
    if [ -f "$HOME/.profile" ]; then
        if ! grep -q ".ssh-agent-init.sh" "$HOME/.profile" 2>/dev/null; then
            cat >> "$HOME/.profile" << 'PROFILE_EOF'

# SSH Agent Initialization
# Skip if running in bash or zsh (handled by .bashrc/.zshrc)
if [ -z "$BASH_VERSION" ] && [ -z "$ZSH_VERSION" ]; then
    if [ -f "$HOME/.ssh-agent-init.sh" ]; then
        . "$HOME/.ssh-agent-init.sh"
    fi
fi
PROFILE_EOF
            echo "✓ Added to ~/.profile"
        else
            echo "✓ ~/.profile already configured"
        fi
    fi

    echo ""
    echo "======================================"
    echo "User installation complete!"
    echo "======================================"
    echo ""
    echo "Configuration files created:"
    echo "  • ~/.ssh-agent-init.sh (main script)"
    if grep -q ".ssh-agent-init.sh" "$HOME/.bashrc" 2>/dev/null; then
        echo "  • ~/.bashrc (auto-load configured)"
    fi
    if grep -q ".ssh-agent-init.sh" "$HOME/.zshrc" 2>/dev/null; then
        echo "  • ~/.zshrc (auto-load configured)"
    fi
    if grep -q ".ssh-agent-init.sh" "$HOME/.profile" 2>/dev/null; then
        echo "  • ~/.profile (auto-load configured)"
    fi
    echo ""
    echo "ssh-agent will automatically start on next login."
    echo "To test immediately, run: source ~/.ssh-agent-init.sh"
    echo ""
fi
