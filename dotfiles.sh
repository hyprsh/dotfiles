
#!/bin/bash

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE="$REPO/config"
DEST="$HOME/.config"

install() {
  rpm-ostree install --apply-live --assumeyes $1
}

link() {
  if ! [[ -L "$DEST"/"$1" ]]; then
    mv $DEST/"$1" $DEST/"$1".bak
    ln -s $SOURCE/"$1" $DEST/"$1"
  fi
}

# sudo without pw
echo "%wheel ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/wheel

# setup automatic updates
# none  - disabled
# check - display updates in `rpm-ostree status`
# stage - download, unpack and finalize after manual reboot
# apply - same as stage but with automatic reboot
sudo sed -i 's/#AutomaticUpdatePolicy=.*/AutomaticUpdatePolicy=stage/g' /etc/rpm-ostreed.conf
sudo systemctl reload rpm-ostreed
sudo systemctl enable rpm-ostreed-automatic.timer --now

# add flatpak remotes, update apps
flatpak remote-add --if-not-exists fedora oci+https://registry.fedoraproject.org
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak remote-add --if-not-exists flathub-beta https://flathub.org/beta-repo/flathub-beta.flatpakrepo
flatpak update --appstream
flatpak update


# install essentials
# install ripgrep duf zoxide tree eza fd jq procs fzf github-cli

# install system pkgs
rpm-ostree install --assumeyes \
	kitty \
	neovim \
	distrobox

# override silverblue default firefox, as we use flatpak for this
rpm-ostree override remove firefox firefox-langpacks

# install flatpak pkgs
flatpak install flathub --assumeyes --noninteractive \
	org.mozilla.firefox \
	com.mattjakeman.ExtensionManager

# install fonts
mkdir -p ~/.local/share/fonts
cp fonts/* ~/.local/share/fonts
fc-cache

# gnome settings
# dcomp blabla

# bash
# mv $HOME/.bashrc $HOME/.bashrc.bak
# ln -s $SOURCE/bash/bashrc $HOME/.bashrc

# bat
# install bat
# link bat
# bat cache --build

# btop
# install btop
# link btop

# chromium
# link chromium-flags.conf

# dunst
# link dunst

# fish
# install fish
# link fish

# gtk3/4
# mkdir -p $HOME/.local/share/icons
# yay -S --noconfirm --needed rose-pine-gtk-theme-full
# link gtk-3.0

# hyprland
# link hypr

# kitty
link kitty

# waybar
# install waybar
# link waybar

# lazygit
# install lazygit
# link lazygit

# neovim
# install nodejs-lts-iron npm gopls
# link nvim

# qutebrowser
# install qutebrowser
# link qutebrowser

# wofi
# link wofi

# yt-dlp
# install yt-dlp
# link yt-dlp

# zsh
# install zsh-syntax-highlighting zsh-autosuggestions
# mv $HOME/.zshrc $HOME/.zshrc.bak
# ln -s $SOURCE/zsh/zshrc $HOME/.zshrc
# sudo chsh nd -s /bin/zsh

# bitwarden-cli
# install bitwarden-cli
# bw config server https://vault.hypr.sh > /dev/null 2>&1
