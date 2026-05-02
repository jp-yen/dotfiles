#!/bin/sh
# 日本語ロケールが入っていること
# dpkg-reconfigure locales

# sources.list のパッケージに non-free contrib を追加
sed -i.orig -e '/^deb.*debian/{s/$/ non-free contrib/}' /etc/apt/sources.list

apt update
apt full-upgrade
apt autoremove
apt purge
apt -y install git locate tcsh vim screen sudo
apt -y remove nano

# edito sudoers のファイルを編集
# visudo

# - optional
apt -y install sharutils gcc make
apt -y install manpages manpages-dev manpages-ja manpages-ja-dev
apt -y install syslog-ng sysstat zip bind9-dnsutils sharutils
# bind9-dnsutils - dig, nslookup
# sharutils - shar, uuencode

# Fedora の場合の日本語ロケール追加
# dnf install glibc-langpack-ja

# インストール済みの一覧
# apt list --installed
# 設定ファイルごとアンインストール
# apt --purge remove <foo>

chsh -s /usr/bin/tcsh
git clone https://github.com/jp-yen/dotfiles.git

echo '' >> /etc/inputrc
echo '$include /etc/inputrc.local' >> /etc/inputrc
install inputrc.local dotfiles/csh.cshrc dotfiles/screenrc /etc/

install dotfiles/vimrc /etc/vim/
install dotfiles/screen.sh /etc/profile.d/


VIM_COLORS=/usr/share/vim/vim90/colors
( cd $VIM_COLORS && wget -N https://raw.githubusercontent.com/michalbachowski/vim-wombat256mod/master/colors/wombat256mod.vim )
( cd $VIM_COLORS && wget -N https://raw.githubusercontent.com/romainl/Apprentice/master/colors/apprentice.vim )
( cd $VIM_COLORS && wget -N https://raw.githubusercontent.com/karoliskoncevicius/moonshine-vim/master/colors/moonshine.vim )
( cd $VIM_COLORS && wget -N https://raw.githubusercontent.com/Haron-Prime/Antares/master/colors/antares.vim )

# for Proxmox
if dmesg | grep -i proxmox > /dev/null ; then
  apt install spice-vdagent
  systemctl start spice-vdagent
  systemctl enable spice-vdagent
  systemctl status spice-vdagent
  mkdir -p /etc/systemd/system/spice-vdagent.service.d/
  cat <<___EOF___> /etc/systemd/system/spice-vdagent.service.d/override.conf
[Service]
ExecStart=
ExecStart=/usr/sbin/spice-vdagentd
___EOF___
  systemctl daemon-reload
  systemctl enable spice-vdagent
fi


exit

# CD インストール net-inst を使うと /etc/apt/sources.list が自動的に更新され便利
# (Cinnamon), SSH, 標準システムユーティリティ
#
# /etc/apt/sources.list の例 https://www.debian.or.jp/using/mirror.html のサンプルを参照

# See sources.list(5) for more information, especially
# Remember that you can only use http, ftp or file URIs
# CDROMs are managed through the apt-cdrom tool.
deb http://cdn.debian.or.jp/debian trixie main contrib non-free non-free-firmware

deb http://security.debian.org/debian-security trixie-security main contrib non-free non-free-firmware

# Uncomment if you want to use Debian stable-updates
deb http://cdn.debian.or.jp/debian trixie-updates trixie-backports main contrib non-free non-free-firmware

# Uncomment if you want the apt-get source function to work
#deb-src http://cdn.debian.or.jp/debian trixie main contrib non-free non-free-firmware
#deb-src http://cdn.debian.or.jp/debian trixie-updates main contrib non-free non-free-firmware

