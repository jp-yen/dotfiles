# SSH Agent 自動起動設定

## 概要

このリポジトリには、SSH Agent を自動起動するための設定スクリプトが含まれています。

- **`ssh-agent-setup.sh`**: スタンドアロンのインストールスクリプト
- **`setup-zsh.sh`**: Zsh セットアップ時に自動的に `ssh-agent-setup.sh` を呼び出します

## 生成されるファイル

### `/etc/ssh-agent-init.sh`
SSH Agent を初期化する共通スクリプトです。以下の処理を行います：
- 既存の ssh-agent が起動しているかチェック
- 必要に応じて新しい ssh-agent を起動
- sh/csh 両形式の環境変数ファイルを生成
- SSH 鍵を自動追加（未登録の場合）

### 環境変数ファイル
- `~/.ssh-agent.sh` - sh/bash/zsh 用の環境変数
- `~/.ssh-agent.csh` - csh/tcsh 用の環境変数

## 各シェルでの使い方

### sh/bash/zsh
```bash
[ -f /etc/ssh-agent-init.sh ] && source /etc/ssh-agent-init.sh
```

### csh/tcsh
```csh
if ( -f /etc/ssh-agent-init.sh ) then
    sh /etc/ssh-agent-init.sh
    if ( -f ~/.ssh-agent.csh ) source ~/.ssh-agent.csh
endif
```

## SSH 鍵の生成

楕円曲線暗号を使用した SSH 鍵の生成方法です。

### Ed25519（推奨）
最速かつ最も安全な楕円曲線暗号（256ビット固定）：
```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

### ECDSA-384（比較的脆弱）
384ビットの楕円曲線暗号：
```bash
ssh-keygen -t ecdsa -b 384 -C "your_email@example.com"
```

**推奨設定：**
- パスフレーズの設定を強く推奨
- デフォルトの保存場所（`~/.ssh/id_ed25519`）を使用

**公開鍵の登録：**
```bash
# 公開鍵の内容を表示
cat ~/.ssh/id_ed25519.pub

# GitHub/GitLab などに登録してください
```

---

スクリプト本体は `ssh-agent-setup.sh` を参照してください。

## システム全体にインストール（root実行）

`sudo bash ./ssh-agent-setup.sh`

**作成されるファイル:**

- `/etc/ssh-agent-init.sh` - メインスクリプト
- `/etc/profile.d/ssh-agent-init.sh` - bash/sh用自動読み込み
- `/etc/zsh/zprofile` - zsh用自動読み込み（追記）
- `/etc/csh/login.d/ssh-agent-init.csh` - csh/tcsh用自動読み込み
    

## 個人ユーザーのみにインストール

`bash ./ssh-agent-setup.sh`

**作成されるファイル:**
- `~/.ssh-agent-init.sh` - メインスクリプト
- `~/.bashrc` - 自動読み込み設定（追記）
- `~/.zshrc` - 自動読み込み設定（追記）
- `~/.profile` - 自動読み込み設定（追記）

## スクリプトの動作

1. **既存のssh-agentをチェック**
    - `~/.ssh-agent.sh`から環境変数を読み込み
    - `SSH_AGENT_PID`が生きているか確認
2. **新しいssh-agentを起動**
    - 必要な場合のみ起動
    - sh/csh両形式の環境変数ファイルを保存
3. **SSH鍵を自動追加**
    - 鍵が未登録の場合のみ`ssh-add`を実行
4. **ログイン時に自動実行**
    - `/etc/profile.d/`経由（システム全体）
    - `.bashrc`/`.zshrc`経由（個人ユーザー）

