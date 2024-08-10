#!/bin/bash

# grub tuning
sed 's/GRUB_GFXMODE=auto/GRUB_GFXMODE=1280x720x32,auto/g' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

# get fastest mirrors
pacman -S --noconfirm reflector
reflector --save /etc/pacman.d/mirrorlist --country Switzerland --protocol https -f 5 -l 5 --verbose
sed -i -e '/Color/s/^#*//' -e '/ParallelDownloads/s/^#*//' /etc/pacman.conf

# install yay
pacman -S --noconfirm --needed git base-devel && git clone https://aur.archlinux.org/yay-bin.git && cd yay-bin && makepkg -si

# nvidia
# pacman -S --noconfirm libva-nvidia-driver
# cat > /etc/modprobe.d/nvidia.conf <<EOF
# options nvidia_drm modeset=1 fbdev=1
# options nvidia NVreg_PreserveVideoMemoryAllocations=1
# EOF
# sed -i 's/kms //g' /etc/mkinitcpio.conf
# mkinitcpio -P
# systemctl enable nvidia-resume.service
# systemctl enable nvidia-hibernate.service
# systemctl enable nvidia-suspend.service

# amd driver
pacman -S --noconfirm mesa lib32-mesa vulkan-radeon lib32-vulkan-radeon libva-mesa-driver libva-utils

# snapper
sed -i 's/subvolid=.*,//' /etc/fstab
yay -S --noconfirm snapper-suppor
umount /.snapshots
rm -r /.snapshots
snapper -c root create-config /
snapper -c root set-config TIMELINE_CREATE=no
btrfs subvolume delete /.snapshots
mkdir /.snapshots
mount -a
snapper -c home create-config /home

# install thunar remove dolphin
pacman -S --noconfirm thunar
pacman -Ru --noconfirm dolphin

