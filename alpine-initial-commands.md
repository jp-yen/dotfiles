#EVE-NG #alpine #Linux

# ダウンロード
https://alpinelinux.org/downloads/

Virtual の iso ファイルをダウンロード。(余計なドライバなどが入っていない)

# iso ファイルを設置
EVE-NG にディレクトリを作成、sftp などでアップロード ISO ファイルを設置
```
cd /opt/unetlab/addons/qemu/linux-alpine-3.33.2
```
名前は cdrom.iso にする
```
mv alpine-virt-3.22.2-x86_64.iso cdrom.iso
```

# ディスクを作成
```
/opt/qemu/bin/qemu-img create -f qcow2 virtioa.qcow2 20G
```

# パーミッションの修正
```
 /opt/unetlab/wrappers/unl_wrapper -a fixpermissions
```

# EVE-NGでノードを追加設定を変更
QEMU custom options を変更
```
-machine type=pc,accel=kvm -vga std -usbdevice tablet -boot order=cd -cpu host
```
		👇へ変更
```
-machine q35,accel=kvm -vga std -usbdevice tablet -boot order=cd -cpu host
```


# EVE-NG で起動してインストール

ログインは root、パスワードはなし

## ネットワークを接続
setup-alpine を実行してネットワークを接続 (必要に応じて proxy なども設定)
```shell
setup-alpine
```
**btrfs を使用しない**なら最後まで実行し、reboot。
btrfs にするならディスクを選択するところで Ctrl+C で止める。


## btrfs ディスクにする場合
インストールに必要なパッケージの追加
```shell
apk update
apk add parted dosfstools btrfs-progs
modprobe btrfs
```

## パーティションを作成
```
parted /dev/vda
```

parted の対話 shell で
```
# GPTパーティションテーブルを作成
mklabel gpt
# EFIパーティションを作成 (512MB)
mkpart ESP fat32 1MiB 513MiB
set 1 esp on
# ルートパーティションを作成 (残り全て)
mkpart primary btrfs 513MiB 100%
# 確認して終了
print
quit
```

### sda の場合の実行例
```
alpine:~# modprobe btrfs
alpine:~# 
alpine:~# parted /dev/sda
GNU Parted 3.6
Using /dev/sda
Welcome to GNU Parted! Type 'help' to view a list of commands.

--- 現在の状態を表示
(parted) p
Model: QEMU QEMU HARDDISK (scsi)
Disk /dev/sda: 215GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags:

Number  Start   End     Size    File system     Name  Flags
 1      1049kB  538MB   537MB   fat32                 boot, esp  👈 この Start, End を使う
 2      538MB   4833MB  4295MB  linux-swap(v1)        swap
 3      4833MB  215GB   210GB   ext4

--- gpt モードで初期化
(parted) mklabel gpt
Warning: The existing disk label on /dev/sda will be destroyed and all data on this disk will be lost. Do you want to continue?
Yes/No? y

--- パーティションを表示
(parted) p free
Model: QEMU QEMU HARDDISK (scsi)
Disk /dev/sda: 215GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags:

Number  Start   End    Size   File system  Name  Flags
        17.4kB  215GB  215GB  Free Space

(parted) mkpart ESP fat32 1049kB  538MB  👈 先ほどの Start, End を使う
(parted) set 1 esp on
(parted)

--- パーティションを表示
(parted) p free
Model: QEMU QEMU HARDDISK (scsi)
Disk /dev/sda: 215GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags:

Number  Start   End     Size    File system  Name  Flags
        17.4kB  1049kB  1031kB  Free Space
 1      1049kB  538MB   537MB   fat32        ESP   boot, esp
        538MB   215GB   214GB   Free Space

--- swap を作成 (開始と終了位置)
(parted) mkpart linux-swap 538MB 4634MB
(parted)
(parted) p free
Model: QEMU QEMU HARDDISK (scsi)
Disk /dev/sda: 215GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags:

Number  Start   End     Size    File system  Name        Flags
        17.4kB  1049kB  1031kB  Free Space
 1      1049kB  538MB   537MB   fat32        ESP         boot, esp
 2      538MB   4634MB  4096MB               linux-swap
        4634MB  215GB   210GB   Free Space

(parted) mkpart primary btrfs 4635MB 100%
(parted)
(parted) p
Model: QEMU QEMU HARDDISK (scsi)
Disk /dev/sda: 215GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags:

Number  Start   End     Size    File system     Name     Flags
 1      1049kB  538MB   537MB   fat32           ESP      boot, esp
 2      538MB   4634MB  4096MB  linux-swap(v1)           swap
 3      4635MB  215GB   210GB   btrfs           primary

(parted) q
Information: You may need to update /etc/fstab.

alpine:~#
alpine:~# mkfs.fat -F 32 /dev/sda1
mkfs.fat 4.2 (2021-01-31)
alpine:~#
alpine:~# mkswap /dev/sda2
Setting up swapspace version 1, size = 4095733760 bytes
UUID=13cb038a-bedf-4971-b597-a9a4ef7d96bc
alpine:~# swapon /dev/sda2
alpine:~#
alpine:~# mount /dev/sda3 /mnt
mount: mounting /dev/sda3 on /mnt failed: Invalid argument
alpine:~# mkfs.btrfs -f /dev/sda3
btrfs-progs v6.17.1
See https://btrfs.readthedocs.io for more information.

Performing full device TRIM /dev/sda3 (195.68GiB) ...
Label:              (null)
UUID:               fdcf1d07-23ec-4c58-b520-9d82038beecd
Node size:          16384
Sector size:        4096        (CPU page size: 4096)
Filesystem size:    195.68GiB
Block group profiles:
  Data:             single            8.00MiB
  Metadata:         DUP               1.00GiB
  System:           DUP               8.00MiB
SSD detected:       yes
Zoned device:       no
Features:           extref, skinny-metadata, no-holes, free-space-tree
Checksum:           crc32c
Number of devices:  1
Devices:
   ID        SIZE  PATH
    1   195.68GiB  /dev/sda3

alpine:~#
alpine:~# mount /dev/sda3 /mnt
alpine:~# mkdir /mnt/boot
alpine:~# mount /dev/sda1 /mnt/boot
alpine:~#
alpine:~# setup-disk -m sys /mnt
Installing system on /dev/sda3:
Installing for x86_64-efi platform.
Installation finished. No error reported.
* creating /boot/initramfs-virt for 6.18.26-0-virt
* Generating grub configuration file ...
* Found linux image: /boot/vmlinuz-virt
* Found initrd image: /boot/initramfs-virt
* Warning: os-prober will not be executed to detect other bootable partitions.
* Systems on them will not be added to the GRUB boot configuration.
* Check GRUB_DISABLE_OS_PROBER documentation entry.
* Adding boot menu entry for UEFI Firmware Settings ...
* done
alpine:~#
alpine:~# blkid /dev/sda2
/dev/sda2: UUID="13cb038a-bedf-4971-b597-a9a4ef7d96bc" TYPE="swap"
alpine:~#
alpine:~# reboot
```
`/etc/fstab` に swap を定義する...のはあとで。

```
UUID=13cb038a-bedf-4971-b597-a9a4ef7d96bc none swap sw 0 0
```
という感じで設定する。(ダブルクォートは含めないこと)
`free -h` でマウントされたことを確認。



## フォーマット
### EFIパーティション
```
mkfs.fat -F 32 /dev/vda1
```
### ルートパーティション (警告は無視してOK)
```
mkfs.btrfs /dev/vda2
...
WARNING: faild to open /dev/btrfs-control, skipping device registration: No such file or directory
```

### Btrfsカーネルモジュールを読み込む
```
modprobe btrfs
```
### ルートパーティションを/mntにマウント
```
mount /dev/vda2 /mnt
```
### マウントポイントを作成
```
mkdir /mnt/boot
```
### EFIパーティションを/mnt/bootにマウント
```
mount /dev/vda1 /mnt/boot
```

# システムのインストールと最終設定
インストールが終わったら再起動
```
setup-disk -m sys /mnt

reboot
```

# システムの設定をする
再起動してきたら設定する
```
setup-alpine
```

# apk リポジトリ (extfs を使わないならここから)
==community を有効化しましょう！==
```
alpine:~# cat /etc/apk/repositories
#/media/cdrom/apks
http://ftp.udx.icscoe.jp/Linux/alpine/v3.23/main
# http://ftp.udx.icscoe.jp/Linux/alpine/v3.23/community	👈 コメントアウトする

http://dl-cdn.alpinelinux.org/alpine/edge/testing	👈 追加する

http://ftp.yz.yamagata-u.ac.jp/pub/linux/alpine/v3.23/main
http://ftp.yz.yamagata-u.ac.jp/pub/linux/alpine/v3.23/community
alpine:~#
```

```
# リポジトリ情報を更新
apk update

# 全パッケージをアップグレード
apk upgrade
```
# terminal データーベースの追加

```
apk add ncurses-terminfo
```

```
# 基本的なネットワークツール
apk add iproute2 iputils tcpdump bind-tools curl wget

# テキストエディタ
apk add nano vim

# SSH関連
apk add openssh-client openssh-server

# マニュアル
apk add mandoc man-pages

# vipw chsh コマンドなど
apk add shadow
```

```
# ping, traceroute, netstat など
apk add iputils iproute2 net-tools mtr

# DNS診断
apk add bind-tools drill

# Telnet/Netcat
apk add busybox-extras netcat-openbsd
```

```
# tcpdump（パケットキャプチャ） tshark（WiresharkのCLI版） ngrep（パケット内容をgrepで検索）
apk add tcpdump tshark ngrep

```

```
# nmap（ポートスキャン）
apk add nmap nmap-scripts

# arp-scan
apk add arp-scan

# fping（複数ホストへの高速ping）
apk add fping
```

```
# iperf3（帯域幅測定）
apk add iperf3

# speedtest-cli（インターネット速度測定）
apk add speedtest-cli

# ab（Apache Bench：HTTP負荷試験）
apk add apache2-utils
```

```
# lighttpd（軽量Webサーバー）
apk add lighttpd

# nginx
apk add nginx

# Python簡易サーバー（既にPythonがある場合）
apk add python3
# python3 -m http.server 8000
```

```
# OpenSSL（証明書確認・暗号化試験）
apk add openssl

# socat（多機能なネットワークリレー）
apk add socat

# hping3（高度なパケット生成ツール）
apk add hping3
```


```
# jq（JSON解析）
apk add jq

# htop（プロセスモニタ）
apk add htop

# tmux/screen（セッション管理）
apk add tmux screen

# git
apk add git

# bash（Alpine標準はash）
apk add bash bash-completion
```

# dotfiles をインストール
```
git clone https://github.com/jp-yen/dotfiles.git

echo '' >> /etc/inputrc
echo '$include /etc/inputrc.local' >> /etc/inputrc
install inputrc.local dotfiles/csh.cshrc dotfiles/screenrc /etc/
install dotfiles/aliases.sh /etc/profile.d/

VIM_COLORS=/usr/share/vim/vim92/colors/
( cd $VIM_COLORS && wget -N https://raw.githubusercontent.com/michalbachowski/vim-wombat256mod/master/colors/wombat256mod.vim )
( cd $VIM_COLORS && wget -N https://raw.githubusercontent.com/romainl/Apprentice/master/colors/apprentice.vim )
( cd $VIM_COLORS && wget -N https://raw.githubusercontent.com/karoliskoncevicius/moonshine-vim/master/colors/moonshine.vim )
( cd $VIM_COLORS && wget -N https://raw.githubusercontent.com/Haron-Prime/Antares/master/colors/antares.vim )
```


# QEMU エージェントをインストール (EVE-NG, proxmox など)
qemu-guest-agent : 実行ファイル本体
qemu-guest-agent-openrc : サービス化用 rc ファイル
```
apk add qemu-guest-agent qemu-guest-agent-openrc

# サービスを自動起動
rc-update add qemu-guest-agent default

# ステータスを確認
rc-service qemu-guest-agent status

# 起動
rc-service qemu-guest-agent start
```

## サービスを削除 (自動起動しない)
# rc-update del qemu-guest-agent default


# IPアドレスの固定
```
setup-interfaces
---
/etc/network/interfaces

auto eth1
iface eth1 inet static
    address 192.168.0.84/24
    gateway 192.168.0.254
    dns-nameservers 192.168.0.251 8.8.8.8
```

# 設定の反映
```
rc-service networking restart
```

# gettyの停止
`tty1` と`ttyS0`だけにする
```
vi /etc/inittab
```
## 設定の反映
```
kill -HUP 1
```

# EVE-NG テンプレートへ反映 (commit)
```
cd /opt/unetlab/tmp/<POD Nr>/<Lab UUID>/<Node ID>/

(例)
cd /opt/unetlab/tmp/0/539beccd-03dd-4cb4-8829-9f096f3f81e2/4

# /opt/qemu/bin/qemu-img commit virtioa.qcow2
Co-routine re-entered recursively
Aborted (core dumped)
	👉 失敗したらもう一度、実行する

# /opt/qemu/bin/qemu-img commit virtioa.qcow2
Image committed.
```

/opt/unetlab/addons/qemu/linux-alpine-virt-3.22.2/virtioa.qcow2 に変更が反映される

```
cd /opt/unetlab/addons/qemu/linux-alpine-virt-3.22.2

root@eve-ng:/opt/unetlab/addons/qemu/linux-alpine-virt-3.22.2# ls -la
total 786128
drwxr-xr-x  2 root root      4096 Oct 13 09:43 .
drwxr-xr-x 51 root root      4096 Oct 13 09:41 ..
-rw-r--r--  1 root root  68157440 Oct 13 09:41 cdrom.iso
-rw-r--r--  1 root root 736886784 Oct 13 22:09 virtioa.qcow2
root@eve-ng:/opt/unetlab/addons/qemu/linux-alpine-virt-3.22.2# rm cdrom.iso
--- ディスクを圧縮
root@eve-ng:/opt/unetlab/addons/qemu/linux-alpine-virt-3.22.2# cp virtioa.qcow2 virtioa.qcow2.old
root@eve-ng:/opt/unetlab/addons/qemu/linux-alpine-virt-3.22.2# /usr/bin/virt-sparsify --compress virtioa.qcow2 compressedvirtioa.qcow2 ; ls -lh ; mv compressedvirtioa.qcow2 virtioa.qcow2
root@eve-ng:/opt/unetlab/addons/qemu/linux-alpine-virt-3.22.2# /opt/unetlab/wrappers/unl_wrapper -a fixpermissions
```



# Web サーバー

## 標準の BusyBox を使用
```
# BusyBoxは標準で入っている
# ドキュメントルートを作成
mkdir -p /var/www/html
echo "Hello from BusyBox!" > /var/www/html/index.html

# Webサーバー起動（ポート8080）
busybox httpd -f -p 8080 -h /var/www/html

# バックグラウンド起動
busybox httpd -p 8080 -h /var/www/html
```

## python3 を使用
```
# カレントディレクトリでWebサーバー起動（ポート8000）
python3 -m http.server 8000

# 特定のディレクトリを公開
python3 -m http.server 8080 --directory /var/www

# すべてのインターフェースで待ち受け
python3 -m http.server 8000 --bind 0.0.0.0

```

## 高速版 (h2o)

### ビルド
```
# ビルド環境準備
apk add git cmake gcc g++ make openssl-dev libuv-dev zlib-dev perl

# h2oをクローン
cd /tmp
git clone --depth 1 https://github.com/h2o/h2o.git
cd h2o

# ビルド
cmake -DCMAKE_INSTALL_PREFIX=/usr/local \
      -DWITH_MRUBY=off \
      .
make -j$(nproc)
make install
```

### 確認
```
/usr/local/bin/h2o --version
```

### TLS 1.3 証明書の生成
```
# 証明書用ディレクトリ作成
mkdir -p /etc/h2o/ssl

# 自己署名証明書生成（RSA 2048bit）
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/h2o/ssl/server.key \
  -out /etc/h2o/ssl/server.crt \
  -subj "/C=JP/ST=Tokyo/L=Tokyo/O=LoadTest/CN=h2o-server"

# または、ECDSAで高速化（推奨）
openssl ecparam -genkey -name prime256v1 -out /etc/h2o/ssl/server.key
openssl req -new -x509 -key /etc/h2o/ssl/server.key \
  -out /etc/h2o/ssl/server.crt -days 365 \
  -subj "/C=JP/ST=Tokyo/L=Tokyo/O=LoadTest/CN=h2o-server"

# パーミッション設定
chmod 600 /etc/h2o/ssl/server.key
chmod 644 /etc/h2o/ssl/server.crt
```


### h2o 設定ファイル（TLS 1.3専用）

```
cat > /etc/h2o/h2o.conf << 'EOF'
# h2o 超高速設定

# ワーカープロセス数（CPUコア数に合わせる）
num-threads: 4

# リスニング設定
listen:
  port: 443
  ssl:
    certificate-file: /etc/h2o/ssl/server.crt
    key-file: /etc/h2o/ssl/server.key
    minimum-version: TLSv1.3
    cipher-suite: TLS_AES_128_GCM_SHA256
    # セッションチケット有効化（高速化）
    session-cache: internal

# HTTP/2最適化
http2-reprioritize-blocking-assets: ON
http2-max-concurrent-requests-per-connection: 512
http2-idle-timeout: 30

# ホスト設定
hosts:
  "default":
    paths:
      /:
        file.dir: /var/www
        # ファイル送信最適化
        file.send-gzip: OFF
        file.send-compressed: OFF
        file.etag: OFF

# ログを無効化（最速）
access-log: /dev/null

# エラーログ
error-log: /var/log/h2o/error.log

# その他の最適化
send-server-name: OFF
max-connections: 10000
EOF
```

### ダミードキュメント
```
# ドキュメントルート作成
mkdir -p /var/www

# 各種サイズのファイル生成
echo "OK" > /var/www/index.html
dd if=/dev/zero of=/var/www/1kb.bin bs=1K count=1
dd if=/dev/zero of=/var/www/1mb.bin bs=1M count=1
dd if=/dev/zero of=/var/www/10mb.bin bs=1M count=10
dd if=/dev/zero of=/var/www/100mb.bin bs=1M count=100

# ログディレクトリ作成
mkdir -p /var/log/h2o
```

###  h2o 起動スクリプト
```
cat > /etc/init.d/h2o << 'EOF'
#!/sbin/openrc-run

name="h2o"
description="H2O HTTP/2 Web Server"
command="/usr/local/bin/h2o"
command_args="-c /etc/h2o/h2o.conf"
pidfile="/var/run/h2o.pid"
command_background="yes"

depend() {
    need net
    after firewall
}

start_pre() {
    checkpath --directory --owner root:root --mode 0755 /var/log/h2o
    checkpath --directory --owner root:root --mode 0755 /var/run
}
EOF

chmod +x /etc/init.d/h2o
```

自動起動設定
```
# h2oを起動
rc-service h2o start

# 自動起動設定
rc-update add h2o default

# 状態確認
rc-service h2o status

# ログ確認
tail -f /var/log/h2o/error.log
```


### 接続試験
curl や openssl を使用
```
# HTTP/2 + TLS 1.3で接続
curl -k -v --http2 https://localhost/index.html

# TLSバージョン確認
curl -k -v --http2 https://localhost/ 2>&1 | grep "TLS"

# ファイルダウンロード速度測定
curl -k -w "\nTime: %{time_total}s\n" https://localhost/10mb.bin -o /dev/null

# 出力例：
# TLSv1.3 (OUT), TLS handshake, Client hello (1):
# TLSv1.3 (IN), TLS handshake, Server hello (2):


# TLS 1.3接続テスト
openssl s_client -connect localhost:443 -tls1_3 -brief

# 暗号スイート確認
echo "GET / HTTP/1.1\r\nHost: localhost\r\n\r\n" | \
  openssl s_client -connect localhost:443 -tls1_3 2>&1 | \
  grep "Cipher"

# 出力例：
# Cipher    : TLS_AES_128_GCM_SHA256
```

## カーネルチューニング
```
# カーネルパラメータ調整
cat >> /etc/sysctl.conf << 'EOF'
# ファイルディスクリプタ上限
fs.file-max = 500000

# TCP設定
net.core.somaxconn = 8192
net.core.netdev_max_backlog = 8192
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_keepalive_time = 600
net.ipv4.tcp_tw_reuse = 1

# ポート範囲拡大
net.ipv4.ip_local_port_range = 10000 65535

# バッファサイズ
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216
EOF

# 反映
sysctl -p

# ulimit設定
ulimit -n 100000

```


# Network setup-scripts
## ホスト名の設定
```
setup-hostname
```

## IPアドレスの設定
```
setup-interfaces
```

## DNSの設定
```
setup-dns
```

## proxyの設定
```
setup-proxy
```

## NTPの起動
```
setup-ntp
```

### ntp の設定ファイル
```
alpine:~# cat /etc/conf.d/ntpd
NTPD_OPTS="-N -p 192.168.0.252 -p 192.168.0.254 -p 192.168.0.251"
alpine:~#
```

### ntp の状態確認
`ntpq -p` や `chronyc sources` のようなコマンドはないのでログから確認する。問題があれば何か出力があるが、問題がなければログは出ない。
```
grep ntpd /var/log/messages
```

# アイコン
[Alpine Linux Icon \| Dashboard Icons](https://dashboardicons.com/icons/alpine-linux)

# docker, docker compose を追加する

```
apk add docker docker-compose
```

docker グループにユーザーを追加
sudo usermod -aG docker $USER

## 自動起動の設定
```
rc-update add docker boot
```

## 起動する
```
service docker start
```

```
❯ docker run --rm chuanwen/cowsay
Unable to find image 'chuanwen/cowsay:latest' locally
latest: Pulling from chuanwen/cowsay
c337767f8c73: Pull complete
99ad4e3ced4d: Pull complete
ec5a723f4e2a: Pull complete
2a175e11567c: Pull complete
8d26426e95e0: Pull complete
46e451596b7c: Pull complete
Digest: sha256:1f7a652a47fe7311c7e201644d44682e11e7ae4d3d7b03c1ce5c0df164de205c
Status: Downloaded newer image for chuanwen/cowsay:latest
 ______________________________________
/ The solution of problems is the most \
| characteristic and peculiar sort of  |
| voluntary thinking.                  |
|                                      |
\ -- William James                     /
 --------------------------------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
```

