
#!/bin/bash

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE="$REPO/config"
DEST="$HOME/.config"

install() {
  sudo pacman -S --noconfirm --needed "$1"
}

link() {
  if ! [[ -L "$DEST"/"$1" ]]; then
    mv $DEST/"$1" $DEST/"$1".bak
    ln -s $SOURCE/"$1" $DEST/"$1"
  fi
}

# sudo without pw
echo "$USER ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/nd

# install essentials
install ripgrep duf zoxide tree bat eza fd jq procs fzf github-cli man-db

# install fonts
mkdir -p ~/.local/share/fonts
cp fonts/* ~/.local/share/fonts
fc-cache

# bash
mv $HOME/.bashrc $HOME/.bashrc.bak
ln -s $SOURCE/bash/bashrc $HOME/.bashrc

# btop
install btop
link btop

# chromium
link chromium-flags.conf

# dunst
install dunst libnotify
link dunst

# fish
install fish
link fish

# gtk3/4
yay -S --noconfirm --needed rose-pine-gtk-theme-full
gsettings set org.gnome.desktop.interface gtk-theme \'rose-pine-gtk\'
link gtk-3.0

# hyprland
install egl-wayland polkit-gnome hyprpaper
link hypr

# kitty
install kitty
link kitty

# waybar
install waybar
link waybar

# lazygit
install lazygit
link lazygit

# neovim
install neovim nodejs-lts-iron npm gopls
link nvim

# qutebrowser
install qutebrowser
link qutebrowser

# wofi
install wofi
link wofi

# yt-dlp
install yt-dlp
link yt-dlp

# bitwarden-cli
install bitwarden-cli
bw config server https://vault.hypr.sh > /dev/null 2>&1
