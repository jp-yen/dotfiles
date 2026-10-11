#!/bin/sh
# Alpine Linux セットアップスクリプト
# debian-initial-commands.md (L45〜) の Alpine 版
#
# root で実行すること:
#   sh alpine-initial-setup.sh
#
# 事前に community リポジトリを有効にしておくこと:
#   /etc/apk/repositories で community の行をアンコメント

set -eu

if [ "$(id -u)" -ne 0 ]; then
  echo "エラー: root で実行してください" >&2
  exit 1
fi

###############################################################################
# パッケージの更新とインストール
###############################################################################

apk update
apk upgrade

# 基本パッケージ
#   tcsh は Alpine リポジトリにないため省略
#   nvi は Alpine リポジトリにないため省略
#   chsh を使うために shadow パッケージが必要
apk add git mlocate zsh vim screen sudo shadow

# nano を削除 (busybox 内蔵の場合は削除不要)
apk del nano 2>/dev/null || true

###############################################################################
# 必要に応じて追加するパッケージ
###############################################################################

# 開発・アーカイブツール
#   build-essential 相当: build-base (gcc, g++, make, musl-dev, etc.)
apk add build-base sharutils zip

# マニュアル
#   Alpine では mandoc を使用。日本語 man は公式リポジトリにない
apk add mandoc man-pages

# システム・ネットワーク監視・ユーティリティ
#   syslog-ng → syslog-ng (community)
#   fdclone は Alpine リポジトリにないため省略
apk add syslog-ng htop net-tools psmisc btrfs-progs

# ネットワーク検証・調査ツール
#   bind9-dnsutils → bind-tools
#   tshark → tshark (community)
#   netcat-openbsd → netcat-openbsd (community)
apk add bind-tools tshark netcat-openbsd fping traceroute nmap wget

# terminal データベース (screen 等で必要)
apk add ncurses-terminfo

###############################################################################
# sudoers の編集
###############################################################################

echo "--- visudo で sudoers を編集してください ---"
# visudo

###############################################################################
# dotfiles のセットアップ
###############################################################################

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if ! grep -q 'inputrc.local' /etc/inputrc 2>/dev/null; then
  echo '' >> /etc/inputrc
  echo '$include /etc/inputrc.local' >> /etc/inputrc
fi
install "$SCRIPT_DIR/inputrc.local" "$SCRIPT_DIR/csh.cshrc" "$SCRIPT_DIR/screenrc" /etc/

install "$SCRIPT_DIR/aliases.sh" /etc/profile.d/

# Alpine の vim 設定
#   /etc/vim/vimrc.local として配置し、vimrc から読み込む
mkdir -p /etc/vim
install "$SCRIPT_DIR/vimrc" /etc/vim/vimrc.local
VIMRC=/etc/vim/vimrc
if [ ! -f "$VIMRC" ] || ! grep -q 'source /etc/vim/vimrc.local' "$VIMRC" 2>/dev/null; then
  echo 'source /etc/vim/vimrc.local' >> "$VIMRC"
fi

# vim カラースキームのダウンロード
VIM_COLORS=$(find /usr/share/vim -maxdepth 1 -type d -name 'vim*' | sort -V | tail -1)/colors
mkdir -p "$VIM_COLORS"
( cd "$VIM_COLORS" && wget -N https://raw.githubusercontent.com/michalbachowski/vim-wombat256mod/master/colors/wombat256mod.vim )
( cd "$VIM_COLORS" && wget -N https://raw.githubusercontent.com/romainl/Apprentice/master/colors/apprentice.vim )
( cd "$VIM_COLORS" && wget -N https://raw.githubusercontent.com/karoliskoncevicius/moonshine-vim/master/colors/moonshine.vim )
( cd "$VIM_COLORS" && wget -N https://raw.githubusercontent.com/Haron-Prime/Antares/master/colors/antares.vim )

###############################################################################
# パフォーマンスモニタ (sysstat)
###############################################################################

apk add sysstat sysstat-openrc

# 取得パラメータを指定:
#   履歴を 200日分保存 (HISTORY=200)
#   取得できるデータを全部取得 (-S XALL)
#   ファイル名を saYYYYMMDD (-D)
SYSSTAT_CONF=/etc/sysstat/sysstat
if [ -f "$SYSSTAT_CONF" ]; then
  cp "$SYSSTAT_CONF" "${SYSSTAT_CONF}.orig"
  sed -i \
    -e '/^HISTORY=/{s/=[0-9]*$/=200/}' \
    -e '/^SADC_OPTIONS=/{s/=.*$/="-D -S XALL"/}' \
    "$SYSSTAT_CONF"
fi

rc-update add sysstat default
rc-service sysstat start

###############################################################################
# Proxmox / QEMU 環境の場合 (qemu-guest-agent)
###############################################################################

if dmesg | grep -qi proxmox; then
  apk add qemu-guest-agent qemu-guest-agent-openrc
  rc-update add qemu-guest-agent default
  rc-service qemu-guest-agent start
  rc-service qemu-guest-agent status || true
fi

###############################################################################
# パッケージ管理のメモ (Alpine/apk)
###############################################################################

echo ""
echo "=== Alpine パッケージ管理メモ ==="
echo "# インストール済みパッケージの一覧"
echo "  apk list --installed"
echo ""
echo "# パッケージのアンインストール"
echo "  apk del <パッケージ名>"
echo ""
echo "# パッケージの検索"
echo "  apk search <キーワード>"
echo ""

echo "--- セットアップ完了 ---"
