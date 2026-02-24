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
btrfs を使用しないなら最後まで実行し、reboot。
btrfs にするならディスクを選択するところで Ctrl+C で止める。


## インストールに必要なパッケージの追加
```shell
apk update
apk add parted dosfstools btrfs-progs
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
http://ftp.udx.icscoe.jp/Linux/alpine/v3.22/main
# http://ftp.udx.icscoe.jp/Linux/alpine/community

http://ftp.yz.yamagata-u.ac.jp/pub/linux/alpine/v3.22/main
http://ftp.yz.yamagata-u.ac.jp/pub/linux/alpine/v3.22/community
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
```

```
# ping, traceroute, netstat など
apk add iputils iproute2 net-tools mtr

# DNS診断
apk add bind-tools drill

# HTTPクライアント
apk add curl wget

# Telnet/Netcat
apk add busybox-extras netcat-openbsd
```

```
# tcpdump（パケットキャプチャ）
apk add tcpdump

# tshark（WiresharkのCLI版）
apk add tshark

# ngrep（パケット内容をgrepで検索）
apk add ngrep
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


# IPアドレスの固定
```
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



# commit
```
cd cd /opt/unetlab/tmp/<POD Nr>/<Lab UUID>/<Node ID>/

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
root@eve-ng:/opt/unetlab/addons/qemu/linux-alpine-virt-3.22.2# mv virtioa.qcow2 virtioa.qcow2.old

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

## 高速版

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

#### ダミードキュメント
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

####  h2o 起動スクリプト
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


#### 接続試験
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

## システムチューニング
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
