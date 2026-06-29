#!/bin/bash -x
set -e
export LANG=C

exec > >(tee /var/log/post_install.log) 2>&1

cd /root ; pwd
env

apt remove -y nano
systemctl enable syslog-ng

# SSH 設定
sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config || echo sshd_config not found

# sudo 設定
echo 'abc123 ALL=(ALL:ALL) ALL' > /etc/sudoers.d/abc123
chmod 440 /etc/sudoers.d/abc123

# sysstat 設定
sed -i.orig -e '/^HISTORY=/{s/=[0-9]*$/=200/}' -e '/^SADC_OPTIONS=/{s/=.*$/="-D -S XALL"/}' /etc/sysstat/sysstat || echo sysstat not found

# NTP 設定
if [ -f /etc/systemd/timesyncd.conf ]; then
    sed -i 's/^#NTP=.*/NTP=192.168.0.252 192.168.0.253 192.168.0.254/' /etc/systemd/timesyncd.conf || echo timesyncd.conf  not found
fi

# dotfiles
# インストール環境で git が入っていることが前提
if [ -d "dotfiles" ]; then rm -rf dotfiles; fi
git clone https://github.com/jp-yen/dotfiles.git
pushd dotfiles/

# /etc/issue に IP アドレスを記入する
install -m 755 refresh-issue-ip/refresh-issue-ip.service /etc/systemd/system/
install -m 500 refresh-issue-ip/refresh-issue-ip.sh      /usr/local/bin/
systemctl daemon-reload
systemctl enable refresh-issue-ip

echo '' >> /etc/inputrc
echo '$include /etc/inputrc.local' >> /etc/inputrc
install inputrc.local csh.cshrc screenrc /etc/

install screen.sh aliases.sh /etc/profile.d/
install vimrc /etc/vim/

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

bash -x setup-zsh.sh
popd

echo "Post-install configuration finished."

