# fedora silverblue setup WIP

## todos

- testing
- hide accesibility stuff
- enable third-part per default
- unpin all dock apps, or display in menu and dock

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
./setup.sh system
```

## 4. reboot

```bash
reboot
```

## 5. Post setup

```sh
cd .dotfiles
./setup.sh enable-extensions
./setup.sh gaming
```
