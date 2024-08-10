# arch setup WIP

## 1. Boot from usb

> If system has nvidia gpu edit boot entry with `e` add `nomodeset` to the end of the line and hit `CTRL+X` to boot the installer.

## 2. Set root password

Set a root password to ssh into the host from a remote host (control machine)

```bash
passwd
```

## 3. Run the setup script

```bash
# download setup.sh
curl -O https://gist.githubusercontent.com/hyprsh/c91791ee3992ad3ada648efd09858d56/raw/2ec47f984b6b038f08a0f86a8f0fa332e62e4601/setup.sh

# edit setup vars
nano setup.sh

# run setup
./setup.sh

```

## 4. reboot

```bash
reboot
```

## 5. dotfiles

```sh
sudo -u nd
git clone https://github.com/hyprsh/dotfiles-arch /home/nd/.dotfiles
cd /home/nd/.dotfiles
./dotfiles.sh
```

