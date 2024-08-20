#!/bin/bash
set -e

SRC="$(pwd)/config"
DST="$HOME/.config"

EXT_LIST=(
	caffeine@patapon.info
	auto-move-windows@gnome-shell-extensions.gcampax.github.com
	blur-my-shell@aunetx
	just-perfection-desktop@just-perfection
	space-bar@luchrioh
	forge@jmmaranan.com
	start-overlay-in-application-view@Hex_cz
	gnome-fuzzy-app-search@gnome-shell-extensions.Czarlie.gitlab.com
	display-brightness-ddcutil@themightydeity.github.com
)

setup_system() {
	rpm-ostree upgrade
	# sudo without pw
	echo "%wheel ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/wheel

	# setup automatic updates
	# none  - disabled
	# check - display updates in `rpm-ostree status`
	# stage - download, unpack and finalize after manual reboot
	# apply - same as stage but with automatic reboot
	sudo sed -i 's/#AutomaticUpdatePolicy=.*/AutomaticUpdatePolicy=stage/g' /etc/rpm-ostreed.conf
	sudo systemctl enable rpm-ostreed-automatic.timer --now

	# install system pkgs
	rpm-ostree install --assumeyes \
		alacritty \
		gnome-tweaks \
		ddcutil \
		btrbk \
		vim

	sudo mkdir -p /etc/btrbk
	sudo tee /etc/btrbk/btrbk.conf <<-EOF
	timestamp_format long
	snapshot_create onchange
	volume /
	  snapshot_dir $HOME/.snapshots
	  subvolume /home
	    snapshot_preserve_min 3h
	    snapshot_preserve 3d 1w 1m
	EOF
	mkdir $HOME/.snapshots

	# override silverblue default firefox, as we use flatpak for this
	rpm-ostree override remove firefox firefox-langpacks

	# add flatpak remotes, update apps
	sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
	sudo flatpak remote-add --if-not-exists flathub-beta https://flathub.org/beta-repo/flathub-beta.flatpakrepo
	flatpak update --appstream --assumeyes
	flatpak update --assumeyes

	# install flatpak pkgs
	flatpak install flathub --assumeyes --noninteractive \
		org.mozilla.firefox

	# ddcutil permissions for brightness control
	echo 'SUBSYSTEM=="i2c-dev", KERNEL=="i2c-[0-9]*", ATTRS{class}=="0x030000", TAG+="uaccess"' | sudo tee /etc/udev/rules.d/60-ddcutil-i2c.rules
	echo "i2c-dev" | sudo tee /etc/modules-load.d/i2c.conf

	# install fonts
	mkdir -p $HOME/.local/share/fonts
	cp fonts/* $HOME/.local/share/fonts
	fc-cache
}

setup_dotfiles() {
	rm -f $HOME/.bashrc && ln -s $SRC/bash/bashrc $HOME/.bashrc
	rm -f $HOME/.inputrc && ln -s $SRC/bash/inputrc $HOME/.inputrc
	ln -s $SRC/alacritty $DST/alacritty
	ln -s $SRC/bat $DST/bat
	ln -s $SRC/btop $DST/btop
	ln -s $SRC/nvim $DST/nvim
	ln -s $SRC/tmux $DST/tmux
	ln -s $SRC/yt-dlp $DST/yt-dlp
}

setup_toolbox() {
	# create toolbox
	toolbox create --assumeyes t
	toolbox run -c t sudo tee -a /etc/dnf/dnf.conf <<-EOF
	max_parallel_dowloads=10
	fastestmirror=True
	installonly_limit=10
	keepcache=True
	defaultyes=True
	EOF
	toolbox run -c t sudo dnf install --assumeyes \
		neovim \
		bat \
		btop \
		ripgrep \
		duf \
		zoxide \
		fd-find \
		procs \
		fzf \
		gh
	toolbox run -c t sudo dnf install --assumeyes https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
	toolbox run -c t sudo dnf groupupdate --assumeyes multimedia --setop="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
}

setup_extensions() {
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

setup_gnome() {
	setup_extensions

	# dconf reset -f /
	dconf load / < config/gnome.dconf
	cp applications/* $HOME/.local/share/applications/
}

setup_gaming() {
	# add rpm fusion repos
	rpm-ostree install --assumeyes --apply-live \
		https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
		https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
	rpm-ostree update
	rpm-ostree install --apply-live --assumeyes steam-devices
	flatpak install flathub --assumeyes --noninteractive \
		com.valvesoftware.Steam \
		com.valvesoftware.Steam.CompatibilityTool.Boxtron \
		com.valvesoftware.Steam.Utility.protontricks \
		com.valvesoftware.SteamLink \
		com.valvesoftware.Steam.Utility.gamescope \
		com.valvesoftware.Steam.CompatibilityTool.Proton-GE \
		org.freedesktop.Platform.VulkanLayer.MangoHud \
		org.freedesktop.Platform.VulkanLayer.vkBasalt \
		com.usebottles.bottles \
		com.heroicgameslauncher.hgl \
		net.lutris.Lutris
	echo "Setup gaming finished, now reboot."
}

setup_virtualization() {
	rpm-ostree install --assumeyes virt-install virt-manager virt-viewer
}

run_setup() {
	echo "Setting up system..."
	setup_system
	echo "Setting up toolbox..."
	setup_toolbox
	echo "Setting up gnome..."
	setup_gnome
	echo "Setting up dotfiles..."
	setup_dotfiles

	# finish
	echo "Setup finished!"
	echo ""
	echo "now reboot your system, and enable gnome extensions: setup.sh extensions"
	echo "gaming setup: setup.sh gaming";
	echo "enable daily backups: sudo enable --now btrbk.timer"
}

case "$1" in
	system) run_setup;;
	gaming) setup_gaming;;
	virtualization) setup_virtualization;;
	*) echo "usage: setup.sh <system|virtualization|gaming>";;
esac

