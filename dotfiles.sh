
#!/bin/bash

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE="$REPO/config"
DEST="$HOME/.config"

dot() {
  mv $DEST/"$1" $DEST/"$1".bak
  ln -s $SOURCE/"$1" $DEST/"$1"
}

# sudo without pw
echo "$USER ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/nd

# install essentials
sudo pacman -S --noconfirm --needed fish neovim reflector hyprpaper nodejs npm ripgrep duf zoxide tree bat eza fd jq procs gopls lazygit fzf github-cli yt-dlp btop man-db

# install fonts
mkdir -p ~/.local/share/fonts
cp fonts/* ~/.local/share/fonts
fc-cache

# bash
mv $HOME/.bashrc $HOME/.bashrc.bak
ln -s $SOURCE/bash/bashrc $HOME/.bashrc

# btop
dot btop

# chromium
mv $DEST/chromium-flags.conf $DEST/chromium-flags.conf.bak
ln -s $SOURCE/chromium-flags.conf $DEST/chromium-flags.conf

# dunst
sudo pacman -S --noconfirm --needed libnotify
dot dunst

# fish
dot fish

# gtk3/4
yay -S --noconfirm --needed rose-pine-gtk-theme-full
gsettings set org.gnome.desktop.interface gtk-theme \'rose-pine-gtk\'
dot gtk-3.0

# hyprland
sudo pacman -S --noconfirm --needed egl-wayland polkit-gnome
dot hypr

# kitty
dot kitty

# waybar
sudo pacman -S --noconfirm --needed waybar
dot waybar

# lazygit
dot lazygit

# neovim
dot nvim

# qutebrowser
dot qutebrowser

# wofi
dot wofi

# yt-dlp
dot yt-dlp
