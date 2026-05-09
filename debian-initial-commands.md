# Debian セットアップ手順

## インストール時の選択

CD net-inst を使うと `/etc/apt/sources.list` が自動的に更新されて便利。

選択するコンポーネント: **Cinnamon**、SSH、標準システムユーティリティ

## /etc/apt/sources.list

[ミラーサイト一覧](https://www.debian.or.jp/using/mirror.html) を参照。

```
deb http://cdn.debian.or.jp/debian trixie main contrib non-free non-free-firmware

deb http://security.debian.org/debian-security trixie-security main contrib non-free non-free-firmware

deb http://cdn.debian.or.jp/debian trixie-updates trixie-backports main contrib non-free non-free-firmware

#deb-src http://cdn.debian.or.jp/debian trixie main contrib non-free non-free-firmware
#deb-src http://cdn.debian.or.jp/debian trixie-updates main contrib non-free non-free-firmware
```

## ロケールの設定

日本語ロケールが入っていること。

```sh
dpkg-reconfigure locales
```

Fedora の場合:

```sh
dnf install glibc-langpack-ja
```

## パッケージの更新とインストール

sources.list に `non-free contrib` を追加してから更新する。

```sh
sed -i.orig -e '/^deb.*debian/{s/$/ non-free contrib/}' /etc/apt/sources.list

apt update
apt full-upgrade
apt autoremove
apt purge
apt -y install git locate tcsh zsh vim nvi screen sudo
apt -y remove nano
```

### 必要に応じて追加するパッケージ

```sh
# 開発・アーカイブツール
apt -y install build-essential sharutils zip

# マニュアル (日本語対応)
apt -y install manpages manpages-dev manpages-ja manpages-ja-dev

# システム・ネットワーク監視・ユーティリティ
apt -y install syslog-ng htop net-tools fdclone psmisc btrfs-progs

# ネットワーク検証・調査ツール
apt -y install bind9-dnsutils nstreams tshark netcat-openbsd fping traceroute nmap wget
```

#### パッケージの説明

- **開発・アーカイブツール**
  - `build-essential`: ソースからのビルドに必要となる基本的なコンパイラ (gcc) やビルドツール (make) のセット
  - `sharutils`: `shar` コマンドや `uuencode`/`uudecode` などのエンコード・デコードツール
  - `zip`: ZIP 形式の圧縮・解凍ツール
- **マニュアル (日本語対応)**
  - `manpages`, `manpages-ja`: 一般コマンドの man ページとその日本語訳
  - `manpages-dev`, `manpages-ja-dev`: C 言語関数などの開発者向け man ページとその日本語訳
- **システム・ネットワーク監視・ユーティリティ**
  - `syslog-ng`: 高機能なシステムログ記録デーモン
  - `htop`: インタラクティブなプロセス・リソース監視ツール
  - `net-tools`: `ifconfig` や `netstat` などの従来型ネットワークツール群
  - `fdclone`: 軽量な CUI ファイラ
  - `psmisc`: `pstree`, `killall`, `fuser` などのプロセス管理ユーティリティ
  - `btrfs-progs`: Btrfs ファイルシステム操作ツール
- **ネットワーク検証・調査ツール**
  - `bind9-dnsutils`: `dig`, `nslookup` などの DNS 問い合わせツール
  - `nstreams`: ネットワークストリームアナライザ
  - `tshark`: Wireshark の CUI 版（パケットキャプチャ）
  - `netcat-openbsd`: ネットワーク接続の読み書きを行う `nc` コマンド
  - `fping`: 複数のホストへの並列 ping ツール
  - `traceroute`: ネットワークの経路探索ツール
  - `nmap`: ポートスキャン・ネットワーク探索ツール
  - `wget`: HTTP/FTP 経由のファイルダウンローダ

## sudoers の編集

```sh
visudo
```

## dotfiles のセットアップ

```sh
chsh -s /usr/bin/tcsh
git clone https://github.com/jp-yen/dotfiles.git

echo '' >> /etc/inputrc
echo '$include /etc/inputrc.local' >> /etc/inputrc
install dotfiles/inputrc.local dotfiles/csh.cshrc dotfiles/screenrc /etc/

install dotfiles/screen.sh dotfiles/aliases.sh /etc/profile.d/
install dotfiles/vimrc /etc/vim/

VIM_COLORS=/usr/share/vim/vim91/colors
( cd $VIM_COLORS && wget -N https://raw.githubusercontent.com/michalbachowski/vim-wombat256mod/master/colors/wombat256mod.vim )
( cd $VIM_COLORS && wget -N https://raw.githubusercontent.com/romainl/Apprentice/master/colors/apprentice.vim )
( cd $VIM_COLORS && wget -N https://raw.githubusercontent.com/karoliskoncevicius/moonshine-vim/master/colors/moonshine.vim )
( cd $VIM_COLORS && wget -N https://raw.githubusercontent.com/Haron-Prime/Antares/master/colors/antares.vim )
```

## パフォーマンスモニタ (sysstat)

インストール

```sh
apt -y install sysstat
```

取得パラメータを指定:

- 履歴を 200日分保存 (`HISTORY=200`)
- 取得できるデータを全部取得 (`-S XALL`)
- ファイル名を `saYYYYMMDD` (`-D`)

```sh
sed -i.orig -e '/^HISTORY=/{s/=[0-9]*$/=200/}' -e '/^SADC_OPTIONS=/{s/=.*$/="-D -S XALL"/}' /etc/sysstat/sysstat

systemctl enable sysstat
systemctl start sysstat
```

## Proxmox で spice を使う場合

```sh
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
```

## パッケージ管理のメモ

```sh
# インストール済みパッケージの一覧
apt list --installed

# 設定ファイルごとアンインストール
apt --purge remove <パッケージ名>
```
