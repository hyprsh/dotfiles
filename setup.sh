
#!/bin/bash

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE="$REPO/config"
DEST="$HOME/.config"

EXT_LIST=(
	caffeine@patapon.info
	auto-move-windows@gnome-shell-extensions.gcampax.github.com
	blur-my-shell@aunetx
	just-perfection-desktop@just-perfection
	space-bar@luchrioh
	forge@jmmaranan.com
	start-overlay-in-application-view@Hex_cz
	gnome-fuzzy-app-search@gnome-shell-extensions.Czarlie.gitlab.com
)

install() {
	rpm-ostree upgrade
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
	# flatpak remote-add --if-not-exists fedora oci+https://registry.fedoraproject.org
	flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
	flatpak remote-add --if-not-exists flathub-beta https://flathub.org/beta-repo/flathub-beta.flatpakrepo
	flatpak update --appstream
	flatpak update

	# install system pkgs
	rpm-ostree install --assumeyes \
		alacritty \
		gnome-tweaks \
		steam-devices

	# override silverblue default firefox, as we use flatpak for this
	rpm-ostree override remove firefox firefox-langpacks

	# install flatpak pkgs
	flatpak install flathub --assumeyes --noninteractive \
		org.mozilla.firefox \

	# install fonts
	mkdir -p $HOME/.local/share/fonts
	cp fonts/* $HOME/.local/share/fonts
	fc-cache

	# install extensions
	install_extensions

	# finish
	echo "Setup finished!"
	echo ""
	echo "now reboot your system."
	echo "enable gnome shell extensions with: ~/.dotfiles/setup.sh enable-extensions"
	echo "configure gnome: ~/.dotfiles/setup.sh setup-gnome"
	echo "setup toolbox with: ~/.dotfiles/setup.sh setup-toolbox";
}

link() {
  if ! [[ -L "$DEST"/"$1" ]]; then
    mv $DEST/"$1" $DEST/"$1".bak
    ln -s $SOURCE/"$1" $DEST/"$1"
  fi
}

setup_dotfiles() {
	link btop
}

install_toolbox() {
	# create toolbox
	toolbox create t
	toolbox run -c t sudo dnf install --assumeyes -q \
		zsh \
		zsh-syntax-highlighting \
		zsh-autosuggestions \
		neovim \
		bat \
		btop \
		ripgrep \
		duf \
		zoxide \
		fd \
		procs \
		fzf \
		gh
}

install_extensions() {
	GN_CMD_OUTPUT=$(gnome-shell --version)
	GN_SHELL=${GN_CMD_OUTPUT:12:2}
	for i in "${EXT_LIST[@]}"
	do
		VERSION_LIST_TAG=$(curl -Lfs "https://extensions.gnome.org/extension-query/?search=${i}" | jq '.extensions[] | select(.uuid=="'"${i}"'")') 
		VERSION_TAG="$(echo "$VERSION_LIST_TAG" | jq '.shell_version_map |."'"${GN_SHELL}"'" | ."pk"')"
		wget -O "${i}".zip "https://extensions.gnome.org/download-extension/${i}.shell-extension.zip?version_tag=$VERSION_TAG"
		gnome-extensions install --force "${i}".zip
		rm ${i}.zip
	done
}

enable_extensions() {
	for i in "${EXT_LIST[@]}"
	do
		gnome-extensions enable "${i}"
	done
}

gather_gnome() {
	dconf dump / > gnome.dconf
}

setup_gnome() {
	dconf reset -f /
	dconf load / < gnome.dconf
}

case "$1" in
	install-extensions) install_extensions;;
	enable-extensions) enable_extensions;;
	setup-dotfiles) setup_dotfiles;;
	setup-toolbox) install_toolbox;;
	setup-gnome) setup_gnome;;
	gather-gnome) gather_gnome;;
	*) install;;
esac

