#!/bin/bash
# Fedora セットアップスクリプト
# debian-initial-commands.md (L45〜) の Fedora 版
#
# root で実行すること:
#   bash fedora-initial-setup.sh

set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
  echo "エラー: root で実行してください" >&2
  exit 1
fi

###############################################################################
# パッケージの更新とインストール
###############################################################################

dnf -y upgrade
dnf -y autoremove

# 基本パッケージ
dnf -y install git plocate tcsh zsh vim-enhanced screen sudo
dnf -y remove nano || true

###############################################################################
# 必要に応じて追加するパッケージ
###############################################################################

# 開発・アーカイブツール
#   build-essential 相当: gcc, gcc-c++, make, glibc-devel, etc.
dnf -y install gcc gcc-c++ make sharutils zip

# マニュアル (日本語対応)
#   Fedora には manpages-ja-dev 相当のパッケージがないため省略
dnf -y install man-pages man-pages-ja

# システム・ネットワーク監視・ユーティリティ
dnf -y install syslog-ng htop net-tools psmisc btrfs-progs

# ネットワーク検証・調査ツール
#   bind9-dnsutils → bind-utils, netcat-openbsd → nmap-ncat
dnf -y install bind-utils wireshark-cli nmap-ncat fping traceroute nmap wget

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

# Fedora の vimrc 配置先
install -D "$SCRIPT_DIR/vimrc" /etc/vimrc.local
if ! grep -q 'source /etc/vimrc.local' /etc/vimrc 2>/dev/null; then
  echo 'source /etc/vimrc.local' >> /etc/vimrc
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

dnf -y install sysstat

# 取得パラメータを指定:
#   履歴を 200日分保存 (HISTORY=200)
#   取得できるデータを全部取得 (-S XALL)
#   ファイル名を saYYYYMMDD (-D)
SYSSTAT_CONF=/etc/sysconfig/sysstat
if [ -f "$SYSSTAT_CONF" ]; then
  sed -i.orig \
    -e '/^HISTORY=/{s/=[0-9]*$/=200/}' \
    -e '/^SADC_OPTIONS=/{s/=.*$/="-D -S XALL"/}' \
    "$SYSSTAT_CONF"
fi

systemctl enable sysstat
systemctl start sysstat

###############################################################################
# Proxmox で spice を使う場合
###############################################################################

if dmesg | grep -qi proxmox; then
  dnf -y install spice-vdagent
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
# パッケージ管理のメモ (Fedora/dnf)
###############################################################################

echo ""
echo "=== Fedora パッケージ管理メモ ==="
echo "# インストール済みパッケージの一覧"
echo "  dnf list --installed"
echo ""
echo "# 設定ファイルごとアンインストール"
echo "  dnf remove <パッケージ名>"
echo ""

echo "--- セットアップ完了 ---"
