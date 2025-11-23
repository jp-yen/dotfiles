# Zsh セットアップガイド

## 前提条件

*   **Alpine Linux**: 事前に `/etc/apk/repositories` の community リポジトリを有効化し、`apk add bash sudo` を実行してください。
*   **フォント**: `Monaspace Xenon` などの Nerd Font 対応フォント推奨。

## インストールとセットアップ

### 1. システムへのインストール（管理者）
システム全体に必要なパッケージと Oh My Zsh をインストールします。
**必ず root 権限で実行してください。**

```bash
sudo bash ./setup-zsh.sh
```

### 2. ユーザーごとのセットアップ（各ユーザー）
各ユーザーで以下のコマンドを実行し、個人設定（`.zshrc` など）を作成します。
**zsh を起動せずに実行してください。** `zsh` を起動してから実行すると、意図しない初期設定ウィザードが開始される可能性があります。

```bash
setup-my-zsh
```

**注意**:
*   既に `~/.zshrc` が存在する場合、スクリプトはファイルを書き換えません。
*   セットアップ後、初めて `zsh` を起動した際に Powerlevel10k の設定ウィザードが自動的に開始されます。

### 3. デフォルトシェルの変更
必要なら、ログインシェルを変更します。

```bash
chsh -s $(which zsh)
```

## SSH Agent 自動起動について

`setup-zsh.sh` は、SSH Agent の自動起動設定も同時にインストールします。

**インストールされるもの:**
- `/etc/ssh-agent-init.sh` - SSH Agent 初期化スクリプト
- 各シェル用の自動読み込み設定

**動作:**
- ログイン時に自動的に ssh-agent が起動します
- 既に起動している場合は、既存のエージェントを再利用します
- SSH 鍵が未登録の場合、`ssh-add` が自動実行されます

**個別インストール:**
ssh-agent の設定だけを個別にインストールしたい場合は、`ssh-agent-setup.sh` を使用してください。
詳細は [ssh-agent.md](ssh-agent.md) を参照してください。

## メンテナンス

### 共有コンポーネントの更新（管理者）
Oh My Zsh 本体やプラグインを一括で更新します。

```bash
sudo update-zsh-shared
```

### アンインストール（個人設定）
以下のコマンドで個人設定を削除できます。

```bash
rm -rf ~/.zsh/cache ~/.zsh/functions.zsh ~/.zshrc ~/.p10k.zsh ~/.p10k-post.zsh ~/.cache/p10k-* ~/p10k-*.zsh ~/.zcompdump*
```

**注意**:
削除後に `zsh` を起動しても、設定ファイル (`.zshrc`) が存在しないため Powerlevel10k は読み込まれず、設定ウィザードも開始されません。
再度セットアップを行う場合は、`setup-my-zsh` を実行してください。

### アンインストール（システム全体・管理者）
システム全体から設定やファイルを削除（クリーンナップ）するには、以下のコマンドを実行してください。
**注意: これを実行すると、全ユーザーの Zsh 環境に影響します。**

```bash
# 共有ファイルと設定の削除
sudo rm -rf /usr/share/oh-my-zsh
sudo rm -rf /etc/zsh/zshrc.d
sudo rm -f /usr/local/bin/setup-my-zsh
sudo rm -f /usr/local/bin/update-zsh-shared
sudo rm -f /etc/ssh-agent-init.sh

# /etc/zshrc (Fedora) または /etc/zsh/zshrc (Debian/Alpine) の修正
# ※ 追記された設定読み込み部分を手動で削除してください
```

## 既存環境への適用（移行・更新）

既にこのスクリプトでセットアップ済みの環境を更新する場合も、同じ手順で実行可能です。

1.  最新のコードを取得します。
    ```bash
    git pull
    ```
2.  セットアップスクリプトを再実行します。
    ```bash
    sudo bash ./setup-zsh.sh
    ```

**更新される内容:**
*   `/etc/zsh/zshrc.d/` 以下のシステム設定ファイルが最新版（OS自動判定対応版）に上書きされます。
*   `/usr/local/bin/` 以下のヘルパースクリプトが更新されます。
*   Fedora環境の場合、`/etc/zshrc` の設定が確認・修正されます。

**ユーザーへの影響:**
*   既存ユーザーの個人設定（`~/.zshrc` など）は**変更されません**。
*   システム設定の更新は、次回のシェル起動時（またはログイン時）から自動的に適用されます。
*   ユーザーが `setup-my-zsh` を再実行する必要はありません（実行しても問題ありませんが、`.p10k-post.zsh` などのカスタム設定が初期化される可能性があるため注意してください）。

## リファレンス：ディレクトリ構成

### 共有ディレクトリ
```
/usr/share/oh-my-zsh/                      # Oh My Zsh本体
├── oh-my-zsh.sh                           # メインスクリプト
├── plugins/                                # 標準プラグイン
└── custom/                                 # カスタマイズ用
    ├── plugins/                            # 追加プラグイン
    │   ├── zsh-autosuggestions/
    │   ├── zsh-syntax-highlighting/
    │   ├── zsh-completions/
    │   └── fzf-tab/
    └── themes/                             # 追加テーマ
        └── powerlevel10k/                  # Powerlevel10kテーマ

/usr/local/bin/                             # ヘルパーコマンド
├── setup-my-zsh                            # ユーザーセットアップ
└── update-zsh-shared                       # 更新コマンド
```

### システム設定
```
/etc/zsh/
├── zshrc.d/                                # 設定ファイル群
│   ├── 00-omz-system.zsh                   # Oh My Zsh設定
│   └── 01-defaults.zsh                     # デフォルト設定・エイリアス
└── zshrc                                   # ローダー
```

### ユーザーディレクトリ
```
$HOME/
├── .zsh/                                   # Zsh関連ファイル
│   ├── cache/                              # キャッシュ
│   └── history                             # 履歴
├── .zshrc                                  # ユーザー設定
├── .p10k.zsh                               # Powerlevel10k設定
└── .p10k-post.zsh                          # Powerlevel10kカスタム設定
```
