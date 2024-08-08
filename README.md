# arch setup WIP

Todo:

- nvim
- yt-dlp
- git
- bat
- eza
- fd
- jq
- fzf
- procs
- ripgrep
- tree
- zoxide
- duf

## 1. Boot from usb

> If system has nvidia gpu edit boot entry with `e` add `nomodeset` to the end of the line and hit `CTRL+X` to boot the installer.

## 2. Set root password

Set a root password to ssh into the host from a remote host (control machine)

```bash
passwd
```

## 3. Prepare installer

Run this step on the `control machine`

```bash
# First copy the user_configuration.json to /root of the installer
scp user_configuration.json root@10.0.0.88:

# ssh into the machine
ssh root@10.0.0.88
```

## 4. Run archinstall

Run archinstall with premade config. It will install arch onto `nvme0n1`

```bash
archinstall --config user_configuration.json
```

You need to create a user with `sudo` on your own, afterwards hit `install`.

## 5. Clone dotfiles in chrooted environment

After the installation is complete, `chroot` into the new system, clone the repo and run `./install.sh`

```sh
sudo -u nd
git clone https://github.com/hyprsh/dotfiles-arch /home/nd/.dotfiles
cd /home/nd/.dotfiles
./install.sh
```

## 6. reboot

```bash
reboot
```

