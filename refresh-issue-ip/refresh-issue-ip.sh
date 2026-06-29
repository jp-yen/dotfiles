#!/bin/bash
# /usr/local/bin/refresh-issue-ip.sh に置く
# サービスを登録する
# /etc/systemd/system/refresh-issue-ip.service

update_issue() {
    local tmpfile=$(mktemp)

    # ログイン画面のベーステキスト
    cat << 'EOF' > "$tmpfile"
Debian GNU/Linux 13 \n \l

IP addr:
EOF

    # ループバック(lo)以外の有効なIPアドレスを綺麗に取得して追記
    ip -br addr show | awk '
    $1 != "lo"{
        iface=$1
        for(i=3; i<=NF; i++) print "  " iface ": " $i
    }' >> "$tmpfile"

    echo "" >> "$tmpfile"

    # 現在の /etc/issue と差分があれば上書き
    if ! cmp -s "$tmpfile" /etc/issue; then
        mv "$tmpfile" /etc/issue
    else
        rm -f "$tmpfile"
    fi
}

# 起動時に一度実行
update_issue

# IPアドレスの変動（追加・削除・変更）をリアルタイムに監視
ip monitor addr | while read -r line; do
    # 短時間に連続でイベントが発生した場合を考慮し、1秒待ってから更新
    sleep 1
    update_issue
done

