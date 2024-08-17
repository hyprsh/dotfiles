# fedora silverblue setup WIP

## 1. Prepare media and run installation

```bash
# download and flash to usb
curl https://download.fedoraproject.org/pub/fedora/linux/releases/40/Silverblue/x86_64/iso/Fedora-Silverblue-ostree-x86_64-40-1.14.iso -O
dd if=Fedora-Silverblue-ostree-x86_64-40-1.14.iso of=/dev/sdX bs=8M status=progress oflag=direct
```

Afterwards boot from media and install silverblue.


## 3. Run the setup script

```bash
git clone https://github.com/hyprsh/dotfiles-arch && cd .dotfiles
./setup.sh

# run setup.sh
./setup.sh
```

## 4. reboot

```bash
reboot
```

## 5. Post setup

```sh
cd .dotfiles
./setup.sh setup-gnome
./setup.sh enable-extensions
./setup.sh setup-dotfiles
./setup.sh setup-toolbox
```
