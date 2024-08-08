
#!/bin/bash

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="$HOME/.config"

# grub tuning
sed 's/GRUB_GFXMODE=auto/GRUB_GFXMODE=1280x720x32,auto/g' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

# sudo without pw
echo "nd ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/nd

# get fastest mirrors
sudo pacman -S --noconfirm reflector
sudo reflector --save /etc/pacman.d/mirrorlist --country Switzerland --protocol https -f 5 -l 5 --verbose
sudo sed -i -e '/Color/s/^#*//' -e '/ParallelDownloads/s/^#*//' /etc/pacman.conf

# install yay
sudo pacman -S --noconfirm --needed git base-devel && git clone https://aur.archlinux.org/yay-bin.git && cd yay-bin && makepkg -si

# install essentials
sudo pacman -S --noconfirm fish neovim reflector hyprpaper

# configure nvidia driver
sudo pacman -S --noconfirm libva-nvidia-driver
cat > /etc/modprobe.d/nvidia.conf <<EOF
options nvidia_drm modeset=1 fbdev=1
options nvidia NVreg_PreserveVideoMemoryAllocations=1
EOF
sed -i 's/kms //g' /etc/mkinitcpio.conf
mkinitcpio -P
systemctl enable nvidia-resume.service
systemctl enable nvidia-hibernate.service
systemctl enable nvidia-suspend.service

# snapper
sudo sed -i 's/subvolid=.*,//' /etc/fstab
yay -S --noconfirm snapper-support
sudo umount /.snapshots
sudo rm -r /.snapshots
sudo btrfs subvolume delete /.snapshots
sudo mkdir /.snapshots
sudo mount -a
sudo snapper -c root create-config /
sudo snapper -c root set-config TIMELINE_CREATE=no
sudo snapper -c home create-config /home

# bash
mv $HOME/.bashrc $HOME/.bashrc.bak
ln -s $DOTFILES/bash/bashrc $HOME/.bashrc

# fish
mv $CONFIG/fish $CONFIG/fish.bak
ln -s $DOTFILES/fish $CONFIG/fish

# hyprland
pacman -S --noconfirm egl-wayland polkit-gnome
mv $CONFIG/hypr $CONFIG/hypr.bak
ln -s $DOTFILES/hypr $CONFIG/hypr

# waybar
pacman -S --noconfirm waybar
mv $CONFIG/waybar $CONFIG/waybar.bak
ln -s $DOTFILES/waybar $CONFIG/waybar

# kitty
mv $CONFIG/kitty $CONFIG/kitty.bak
ln -s $DOTFILES/kitty $CONFIG/kitty

# gtk3/4
yay -S --noconfirm rose-pine-gtk-theme-full
gsettings set org.gnome.desktop.interface
 gtk-theme \'rose-pine-gtk\'
mv $CONFIG/gtk-3.0 $CONFIG/gtk-3.0.bak
ln -s $DOTFILES/gtk-3.0 $CONFIG/gtk-3.0

# dunst
sudo pacman -S --noconfirm libnotify
mv $CONFIG/dunst $CONFIG/dunst.bak
ln -s $DOTFILES/dunst $CONFIG/dunst

# install fonts
mkdir ~/.local/share/fonts
cp fonts/* ~/.local/share/fonts
fc-cache

# install thunar remove dolphin
sudo pacman -S --noconfirm thunar
sudo pacman -Ru dolphin

