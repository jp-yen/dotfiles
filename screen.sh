# screen コマンドが存在する場合のみエイリアスを設定
if command -v screen > /dev/null 2>&1; then
        alias screen="$(command -v screen) -U -D -RR"
fi

# cygwin や WSL など、/var/run/screen 問題の回避
export SCREENDIR="$HOME/.screen"
if [ ! -d "$SCREENDIR" ]; then
        mkdir "$SCREENDIR" && chmod 700 "$SCREENDIR"
fi
