#!/bin/bash -x
set -e
export LANG=C

exec > >(tee /var/log/post_install.log) 2>&1

env

# SSH 設定 (インストール済みである前提)
if [ -f /etc/ssh/sshd_config ]; then
    sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
fi
# systemctl は実行せず、自動起動設定はインストール後の初回起動に任せる

# sudo 設定
echo 'abc123 ALL=(ALL:ALL) ALL' > /etc/sudoers.d/abc123
chmod 440 /etc/sudoers.d/abc123

# sysstat 設定
if [ -f /etc/sysstat/sysstat ]; then
    sed -i.orig -e '/^HISTORY=/{s/=[0-9]*$/=200/}' -e '/^SADC_OPTIONS=/{s/=.*$/="-D -S XALL"/}' /etc/sysstat/sysstat
fi

# NTP 設定
if [ -f /etc/systemd/timesyncd.conf ]; then
    sed -i 's/^#NTP=.*/NTP=192.168.0.252 192.168.0.253 192.168.0.254/' /etc/systemd/timesyncd.conf
fi
# systemctl restart systemd-timesyncd は実行しない

# dotfiles
# インストール環境で git が入っていることが前提
if [ -d "dotfiles" ]; then rm -rf dotfiles; fi
git clone https://github.com/jp-yen/dotfiles.git

echo '' >> /etc/inputrc
echo '$include /etc/inputrc.local' >> /etc/inputrc
install dotfiles/inputrc.local dotfiles/csh.cshrc dotfiles/screenrc /etc/

install dotfiles/screen.sh dotfiles/aliases.sh /etc/profile.d/
install dotfiles/vimrc /etc/vim/

VIM_COLORS=$(ls -d /usr/share/vim/vim*/colors | head -n 1)
if [ -n "$VIM_COLORS" ] && [ -d "$VIM_COLORS" ]; then
    (
      cd "$VIM_COLORS" && \
      wget -N https://raw.githubusercontent.com/michalbachowski/vim-wombat256mod/master/colors/wombat256mod.vim && \
      wget -N https://raw.githubusercontent.com/romainl/Apprentice/master/colors/apprentice.vim && \
      wget -N https://raw.githubusercontent.com/karoliskoncevicius/moonshine-vim/master/colors/moonshine.vim && \
      wget -N https://raw.githubusercontent.com/Haron-Prime/Antares/master/colors/antares.vim
    )
else
    echo "Warning: VIM colors directory not found."
fi

bash -x dotfiles/setup-zsh.sh

echo "Post-install configuration finished."

