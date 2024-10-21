#!/bin/bash
set -e

SRC="$(pwd)/config"
DST="$HOME/.config"

setup_system() {

sudo -v

# update system
sudo rpm-ostree update && sudo rpm-ostree upgrade

# setup automatic updates
# stage - download, unpack and finalize after manual reboot
sudo sed -i 's/#AutomaticUpdatePolicy=.*/AutomaticUpdatePolicy=stage/g' /etc/rpm-ostreed.conf
sudo systemctl enable rpm-ostreed-automatic.timer --now

# install system pkgs
sudo rpm-ostree install --assumeyes --idempotent gnome-tweaks steam-devices

# virtualization (disabled, use boxes instead)
#rpm-ostree install --assumeyes virt-install virt-manager 

# override silverblue default firefox, as we use flatpak for this
sudo rpm-ostree override remove firefox firefox-langpacks

# add flatpak remotes, update apps
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
# sudo flatpak remote-add --if-not-exists flathub-beta https://flathub.org/beta-repo/flathub-beta.flatpakrepo
sudo flatpak update --appstream --assumeyes

# install flatpak pkgs
flatpak install flathub --assumeyes --noninteractive \
	org.mozilla.firefox \
	org.gnome.World.PikaBackup \
	com.valvesoftware.Steam \
	net.lutris.Lutris \
	org.freedesktop.Platform.ffmpeg-full//24.08 \
	com.github.tchx84.Flatseal \
	org.gnome.Boxes \
	com.github.marhkb.Pods

# setup toolbox
toolbox create --assumeyes &&
toolbox run sudo dnf install --assumeyes \
	bat btop duf eza fd-find fzf gh neovim procs ripgrep tealdeer \
	tmux trash-cli yq jq ugrep zoxide
toolbox run sudo dnf copr enable atim/lazygit -assumeyes && sudo dnf install --assumeyes lazygit

# install fonts
mkdir -p $HOME/.local/share/fonts
cp fonts/* $HOME/.local/share/fonts
fc-cache

# setup dotfiles
rm -f $HOME/.bashrc && ln -s $SRC/bash/bashrc $HOME/.bashrc
rm -f $HOME/.inputrc && ln -s $SRC/bash/inputrc $HOME/.inputrc
ln -s $SRC/git $DST/git
ln -s $SRC/lazygit $DST/lazygit
ln -s $SRC/nvim $DST/nvim
ln -s $SRC/tmux $DST/tmux
ln -s $SRC/yt-dlp $DST/yt-dlp
	
# setup gnome
dconf load / < config/gnome/gnome.dconf
cp applications/* $HOME/.local/share/applications/

# setup gnome extensions
install_extensions \
	blur-my-shell@aunetx \
	caffeine@patapon.info \
	just-perfection-desktop@just-perfection \
	gnome-fuzzy-app-search@gnome-shell-extensions.Czarlie.gitlab.com \
	tilingshell@ferrarodomenico.com \
	Vitals@CoreCoding.com \
gnome-extensions disable background-logo@fedorahosted.org

}

install_extension() {
for i in "$@"; do
    GN_SHELL=$(gnome-shell --version | cut -d' ' -f3 | cut -d'.' -f1)
    VERSION_TAG=$(curl -s "https://extensions.gnome.org/extension-query/?search=${i}" |
        jq -r '.extensions[] | select(.uuid=="'"${i}"'") | .shell_version_map | .["'"${GN_SHELL}"'"] | .pk')
    wget -qO "${i}.zip" "https://extensions.gnome.org/download-extension/${i}.shell-extension.zip?version_tag=$VERSION_TAG" &&
    gnome-extensions install --force "${i}.zip" &&
    gnome-extensions enable "${i}" &&
    rm "${i}.zip"
done
}

setup_system

