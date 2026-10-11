#!/bin/bash
# Ubuntu セットアップスクリプト
# debian-initial-commands.md (L45〜) の Ubuntu 版
#
# root で実行すること:
#   bash ubuntu-initial-setup.sh

set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
  echo "エラー: root で実行してください" >&2
  exit 1
fi

###############################################################################
# パッケージの更新とインストール
###############################################################################

apt update
apt -y full-upgrade
apt -y autoremove --purge

# 基本パッケージ
apt -y install git locate tcsh zsh vim nvi screen sudo
apt -y remove nano || true

###############################################################################
# 必要に応じて追加するパッケージ
###############################################################################

# 開発・アーカイブツール
apt -y install build-essential sharutils zip

# マニュアル (日本語対応)
apt -y install manpages manpages-dev manpages-ja manpages-ja-dev

# システム・ネットワーク監視・ユーティリティ
apt -y install syslog-ng htop net-tools fdclone psmisc btrfs-progs

# ネットワーク検証・調査ツール
apt -y install bind9-dnsutils nstreams tshark netcat-openbsd fping traceroute nmap wget

###############################################################################
# sudoers の編集
###############################################################################

echo "--- visudo で sudoers を編集してください ---"
# visudo

###############################################################################
# dotfiles のセットアップ
###############################################################################

# chsh -s /usr/bin/tcsh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if ! grep -q 'inputrc.local' /etc/inputrc 2>/dev/null; then
  echo '' >> /etc/inputrc
  echo '$include /etc/inputrc.local' >> /etc/inputrc
fi
install "$SCRIPT_DIR/inputrc.local" "$SCRIPT_DIR/csh.cshrc" "$SCRIPT_DIR/screenrc" /etc/

install "$SCRIPT_DIR/screen.sh" "$SCRIPT_DIR/aliases.sh" /etc/profile.d/
install "$SCRIPT_DIR/vimrc" /etc/vim/

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

apt -y install sysstat

# 取得パラメータを指定:
#   履歴を 200日分保存 (HISTORY=200)
#   取得できるデータを全部取得 (-S XALL)
#   ファイル名を saYYYYMMDD (-D)
sed -i.orig \
  -e '/^HISTORY=/{s/=[0-9]*$/=200/}' \
  -e '/^SADC_OPTIONS=/{s/=.*$/="-D -S XALL"/}' \
  /etc/sysstat/sysstat

systemctl enable sysstat
systemctl start sysstat

###############################################################################
# Proxmox で spice を使う場合
###############################################################################

if dmesg | grep -qi proxmox; then
  apt -y install spice-vdagent
  systemctl start spice-vdagent
  systemctl enable spice-vdagent
  systemctl status spice-vdagent || true
  mkdir -p /etc/systemd/system/spice-vdagent.service.d/
  cat <<'___EOF___'> /etc/systemd/system/spice-vdagent.service.d/override.conf
[Service]
ExecStart=
ExecStart=/usr/sbin/spice-vdagentd
___EOF___
  systemctl daemon-reload
  systemctl enable spice-vdagent
fi

###############################################################################
# パッケージ管理のメモ (Ubuntu/apt)
###############################################################################

echo ""
echo "=== Ubuntu パッケージ管理メモ ==="
echo "# インストール済みパッケージの一覧"
echo "  apt list --installed"
echo ""
echo "# 設定ファイルごとアンインストール"
echo "  apt --purge remove <パッケージ名>"
echo ""

echo "--- セットアップ完了 ---"
