#!/bin/bash

set -u

disk=/dev/nvme0n1
username=nd
password=Welcome0
hostname=arch
locale=en_GB # instead of en_US for metric units
gpu=amd # or nvidia
kblayout=us

# Installation

## Updating the live environment usually causes more problems than its worth, and quite often can't be done without remounting cowspace with more capacity, especially at the end of any given month.
pacman -Sy

## Installing curl
pacman -S --noconfirm curl

## Wipe the disk
sgdisk --zap-all "${disk}"

## Creating a new partition scheme.
output "Creating new partition scheme on ${disk}."
sgdisk -g "${disk}"
sgdisk -I -n 1:0:+512M -t 1:ef00 -c 1:'ESP' "${disk}"
sgdisk -I -n 2:0:0 -c 2:'rootfs' "${disk}"

ESP='/dev/disk/by-partlabel/ESP'
BTRFS='/dev/disk/by-partlabel/rootfs'

## Informing the Kernel of the changes.
output 'Informing the Kernel about the disk changes.'
partprobe "${disk}"

## Formatting the ESP as FAT32.
output 'Formatting the EFI Partition as FAT32.'
mkfs.fat -F 32 -s 2 "${ESP}"

## Formatting the partition as BTRFS.
output 'Formatting the rootfs as BTRFS.'
mkfs.btrfs "${BTRFS}"
mount "${BTRFS}" /mnt

## Creating BTRFS subvolumes.
output 'Creating BTRFS subvolumes.'

btrfs su cr /mnt/@
btrfs su cr /mnt/@/.snapshots
mkdir -p /mnt/@/.snapshots/1
btrfs su cr /mnt/@/.snapshots/1/snapshot
btrfs su cr /mnt/@/boot/
btrfs su cr /mnt/@/home
btrfs su cr /mnt/@/root
btrfs su cr /mnt/@/srv
btrfs su cr /mnt/@/var_log
btrfs su cr /mnt/@/var_crash
btrfs su cr /mnt/@/var_cache
btrfs su cr /mnt/@/var_tmp
btrfs su cr /mnt/@/var_spool
btrfs su cr /mnt/@/var_lib_libvirt_images
btrfs su cr /mnt/@/var_lib_machines

## Disable CoW on subvols we are not taking snapshots of
chattr +C /mnt/@/boot
chattr +C /mnt/@/home
chattr +C /mnt/@/root
chattr +C /mnt/@/srv
chattr +C /mnt/@/var_log
chattr +C /mnt/@/var_crash
chattr +C /mnt/@/var_cache
chattr +C /mnt/@/var_tmp
chattr +C /mnt/@/var_spool
chattr +C /mnt/@/var_lib_libvirt_ima

## Set the default BTRFS Subvol to Snapshot 1 before pacstrapping
btrfs subvolume set-default "$(btrfs subvolume list /mnt | grep "@/.snapshots/1/snapshot" | grep -oP '(?<=ID )[0-9]+')" /mnt

cat > /mnt/@/.snapshots/1/info.xml <<EOF
<?xml version=\"1.0\"?>
<snapshot>
  <type>single</type>
  <num>1</num>
  <date>${installation_date}</date>
  <description>First Root Filesystem</description>
  <cleanup>number</cleanup>
</snapshot>
EOF

chmod 600 /mnt/@/.snapshots/1/info.xml

## Mounting the newly created subvolumes.
umount /mnt
output 'Mounting the newly created subvolumes.'
mount -o ssd,noatime,compress=zstd "${BTRFS}" /mnt
mkdir -p /mnt/{boot,root,home,.snapshots,srv,tmp,var/log,var/crash,var/cache,var/tmp,var/spool,var/lib/libvirt/images,var/lib/machines}

mount -o noatime,compress=zstd,subvol=@/boot "${BTRFS}" /mnt/boot
mount -o noatime,compress=zstd,subvol=@/root "${BTRFS}" /mnt/root
mount -o noatime,compress=zstd,subvol=@/home "${BTRFS}" /mnt/home
mount -o noatime,compress=zstd,subvol=@/.snapshots "${BTRFS}" /mnt/.snapshots
mount -o noatime,compress=zstd,subvol=@/srv "${BTRFS}" /mnt/srv
mount -o noatime,compress=zstd,nodatacow,subvol=@/var_log "${BTRFS}" /mnt/var/log
mount -o noatime,compress=zstd,nodatacow,subvol=@/var_crash "${BTRFS}" /mnt/var/crash
mount -o noatime,compress=zstd,nodatacow,subvol=@/var_cache "${BTRFS}" /mnt/var/cache
mount -o noatime,compress=zstd,nodatacow,subvol=@/var_tmp "${BTRFS}" /mnt/var/tmp
mount -o noatime,compress=zstd,nodatacow,subvol=@/var_spool "${BTRFS}" /mnt/var/spool
mount -o noatime,compress=zstd,nodatacow,subvol=@/var_lib_libvirt_images "${BTRFS}" /mnt/var/lib/libvirt/images
mount -o noatime,compress=zstd,nodatacow,subvol=@/var_lib_machines "${BTRFS}" /mnt/var/lib/machines

mkdir -p /mnt/boot/efi
mount "${ESP}" /mnt/boot/efi

## Pacstrap
output 'Installing the base system (it may take a while).'

CPU=$(grep vendor_id /proc/cpuinfo)
if [[ "${CPU}" == *"AuthenticAMD"* ]]; then
    microcode=amd-ucode
else
    microcode=intel-ucode
fi

# base packages
pacstrap /mnt apparmor base base-devel efibootmgr firewalld grub grub-btrfs inotify-tools linux-firmware linux nano reflector sbctl snapper snap-pac sudo zram-generator "${microcode}" neovim networkmanager flatpak pipewire-alsa pipewire-pulse pipewire-jack wireplumber fwupd wget curl zsh zsh-completions git openssh unzip man-db man-pages texinfo

echo 'UriSchemes=file;https' >> /mnt/etc/fwupd/fwupd.conf
sed -i -e '/Color/s/^#*//' -e '/ParallelDownloads/s/^#*//' /mnt/etc/pacman.conf

if [ "${gpu}" = 'amd' ]; then
    pacstrap /mnt mesa lib32-mesa vulkan-radeon lib32-vulkan-radeon libva-mesa-driver libva-utils
elif [ "${gpu}" = 'nvidia' ]; then
    pacstrap /mnt nvidia-dkms nvidia-utils libva-nvidia-driver egl-wayland lib32-nvidia-utils nvidia-settings
    cat > /mnt/etc/modprobe.d/nvidia.conf <<EOF
options nvidia_drm modeset=1 fbdev=1
options nvidia NVreg_PreserveVideoMemoryAllocations=1
EOF
sed -i 's/kms //g' /mnt/etc/mkinitcpio.conf
fi

# hyprland packages
pacstrap /mnt xdg-desktop-portal-hyprland xdg-utils polkit-gnome hyprland hyprpaper hyprlock hypridle nwg-look dunst wofi grim slurp thunar cliphist kitty qt5-wayland qt6-wayland lemurs

## configure lemurs display manager
cat > /mnt/etc/lemurs/wayland/hyprland <<EOF
#! /bin/sh
exec Hyprland
EOF
chmod 755 /mnt/etc/lemurs/wayland/hyprland

## Generate /etc/fstab.
output 'Generating a new fstab.'
genfstab -U /mnt >> /mnt/etc/fstab
sed -i 's#,subvolid=258,subvol=/@/.snapshots/1/snapshot,subvol=@/.snapshots/1/snapshot##g' /mnt/etc/fstab

output 'Setting up hostname, locale and keyboard layout'

## Set hostname.
echo "$hostname" > /mnt/etc/hostname

## Setting hosts file.
echo 'Setting hosts file.'
echo "127.0.0.1   localhost
::1         localhost
127.0.1.1   $hostname.localdomain   $hostname" > /mnt/etc/hosts

## Setup locales.
echo "$locale.UTF-8 UTF-8"  > /mnt/etc/locale.gen
echo "LANG=$locale.UTF-8" > /mnt/etc/locale.conf

## Setup keyboard layout.
echo "KEYMAP=$kblayout" > /mnt/etc/vconsole.conf

## Configure /etc/mkinitcpio.conf
sed -i 's/#COMPRESSION="zstd"/COMPRESSION="zstd"/g' /mnt/etc/mkinitcpio.conf
sed -i 's/^MODULES=.*/MODULES=(btrfs)/g' /mnt/etc/mkinitcpio.conf

## Configure grub
sed -i 's/GRUB_GFXMODE=.*/GRUB_GFXMODE=1280x720x32,auto/g' /mnt/etc/default/grub
sed -i 's/ part_msdos//g' /mnt/etc/default/grub
cat >> /mnt/etc/default/grub <<EOF

GRUB_BTRFS_OVERRIDE_BOOT_PARTITION_DETECTION=true
EOF

# Disable root subvol pinning. !IMPORTANT!
sed -i 's/rootflags=subvol=${rootsubvol}//g' /mnt/etc/grub.d/10_linux

cat > /mnt/etc/systemd/zram-generator.conf <<EOF
[zram0]
zram-fraction = 1
max-zram-size = 8192
compression-algorithm = zstd
EOF

## Configuring the system.
arch-chroot /mnt /bin/bash -e <<EOF

    # Setting up timezone
    # Temporarily hardcoding here
    ln -sf /usr/share/zoneinfo/Europe/Zurich /etc/localtime

    # Setting up clock
    hwclock --systohc

    # Generating locales
    locale-gen

    # Create SecureBoot keys
    # This isn't strictly necessary, but linux-hardened preset expects it and mkinitcpio will fail without it
    # sbctl create-keys

    # Generating a new initramfs
    chmod 600 /boot/initramfs-linux*
    mkinitcpio -P

    # Installing GRUB
    grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB --disable-shim-lock

    # Creating grub config file
    grub-mkconfig -o /boot/grub/grub.cfg

    # Adding user with sudo privilege
    useradd -m $username
    usermod -aG wheel $username

    # Setting up dconf
    dconf update

    # Use systemd-resolved for DNS resolution
    rm /etc/resolv.conf
    ln -s /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

    # Snapper configuration
    umount /.snapshots
    rm -r /.snapshots
    snapper --no-dbus -c root create-config /
    btrfs subvolume delete /.snapshots
    mkdir /.snapshots
    mount -a
    chmod 750 /.snapshots

    # install yay
    git clone https://aur.archlinux.org/yay-bin.git
    cd yay-bin
    makepkg -si
EOF

## Set user password.
[ -n "$username" ] && echo "Setting user password for ${username}." && echo -e "${user_password}\n${user_password}" | arch-chroot /mnt passwd "$username"

## Give wheel user sudo access.
sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/g' /mnt/etc/sudoers

## Enable services
systemctl enable apparmor --root=/mnt
systemctl enable firewalld --root=/mnt
systemctl enable fstrim.timer --root=/mnt
systemctl enable grub-btrfsd.service --root=/mnt
systemctl enable reflector.timer --root=/mnt
systemctl enable snapper-timeline.timer --root=/mnt
systemctl enable snapper-cleanup.timer --root=/mnt
systemctl enable systemd-oomd --root=/mnt
systemctl enable lemurs --root=/mnt
systemctl enable NetworkManager --root=/mnt
systemctl enable systemd-resolved --root=/mnt
systemctl enable sshd --root=/mnt

if [ "${gpu}" = 'nvidia' ]; then
systemctl enable nvidia-resume.service --root=/mnt
systemctl enable nvidia-hibernate.service --root=/mnt
systemctl enable nvidia-suspend.service --root=/mnt
fi
