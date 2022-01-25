From archlinux

ADD ./pacman_mirrorlist /etc/pacman.d/mirrorlist

# WORKAROUND for glibc 2.33 and old Docker
# See https://github.com/actions/virtual-environments/issues/2658
# Thanks to https://github.com/lxqt/lxqt-panel/pull/1562
RUN patched_glibc=glibc-linux4-2.33-5-x86_64.pkg.tar.zst \
    && curl -LO "https://repo.archlinuxcn.org/x86_64/$patched_glibc" \
    && bsdtar -C / -xvf "$patched_glibc" \
    && rm -f "$patched_glibc"

RUN echo -e "\n[multilib]\nInclude = /etc/pacman.d/mirrorlist" >> /etc/pacman.conf \
    && echo -e "\n[archlinuxcn]\nSigLevel = Never\nServer = http://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/\$arch" >> /etc/pacman.conf \
    && pacman -Sy --noconfirm yay git sudo fakeroot binutils make patch which \
    && useradd user -d /home/user -m \
    && echo "%user ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/user \
    && su - user -c "yay -S --noconfirm deepin-wine6-stable" \
    && su - user -c "yay -S --noconfirm deepin-wine-helper" \
    && su - user -c "yay -S --noconfirm deepin-wine-wechat" \
    && su user -c "yay -Scc --noconfirm" \
    && pacman -Scc --noconfirm \
    && userdel -r user

ENTRYPOINT ["/opt/apps/com.qq.weixin.deepin/files/run.sh"]
