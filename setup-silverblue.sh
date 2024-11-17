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
	sudo rpm-ostree install --assumeyes --idempotent alacritty gnome-tweaks steam-devices

	# wezterm
	sudo rpm-ostree install --assumeyes https://github.com/wez/wezterm/releases/download/nightly/wezterm-nightly-fedora40.rpm

	# virtualization (disabled, use boxes instead)
	#rpm-ostree install --assumeyes virt-install virt-manager

	# override silverblue default firefox, as we use flatpak for this
	sudo rpm-ostree override remove firefox firefox-langpacks || true

	# add flatpak remotes, update apps
	sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
	# sudo flatpak remote-add --if-not-exists flathub-beta https://flathub.org/beta-repo/flathub-beta.flatpakrepo
	sudo flatpak update --appstream --assumeyes

	# install flatpak pkgs
	flatpak install flathub --assumeyes --noninteractive \
		org.mozilla.firefox \
		io.github.zen_browser.zen \
		org.gnome.World.PikaBackup \
		com.valvesoftware.Steam \
		net.lutris.Lutris \
		org.freedesktop.Platform.ffmpeg-full//24.08 \
		com.github.tchx84.Flatseal \
		org.gnome.Boxes \
		com.discordapp.Discord \
		com.github.marhkb.Pods

	# setup toolbox
	toolbox create --assumeyes &>/dev/null
	toolbox run sudo dnf install --assumeyes \
		bat btop duf eza fd-find fzf gh neovim procs ripgrep tealdeer \
		tmux trash-cli yq jq ugrep zoxide luarocks host-spawn
	toolbox run sudo dnf copr enable atim/lazygit --assumeyes &>/dev/null && toolbox run sudo dnf install --assumeyes lazygit

	# install fonts
	mkdir -p $HOME/.local/share/fonts
	curl -L https://github.com/be5invis/Iosevka/releases/download/v32.0.1/SuperTTC-Iosevka-32.0.1.zip -o /tmp/iosevka.zip
	unzip iosevka.zip -d $HOME/.local/share/fonts
	rm /tmp/iosevka.zip
	fc-cache

	# install scripts
	# mkdir -p $HOME/.local/bin
	# cp scripts/* $HOME/.local/bin

	# setup dotfiles
	rm -f $HOME/.bashrc && ln -s $SRC/bash/bashrc $HOME/.bashrc
	rm -f $HOME/.inputrc && ln -s $SRC/bash/inputrc $HOME/.inputrc
	ln -s $SRC/wezterm $DST/wezterm
	ln -s $SRC/containers $DST/containers
	ln -s $SRC/git $DST/git
	ln -s $SRC/lazygit $DST/lazygit
	ln -s $SRC/nvim $DST/nvim
	ln -s $SRC/tmux $DST/tmux
	ln -s $SRC/yt-dlp $DST/yt-dlp

	# install gnome extensions
	install_extension \
		blur-my-shell@aunetx \
		caffeine@patapon.info \
		just-perfection-desktop@just-perfection \
		gnome-fuzzy-app-search@gnome-shell-extensions.Czarlie.gitlab.com \
		gTile@vibou \
		Vitals@CoreCoding.com

	# setup gnome
	dconf load /org/gnome/ <config/gnome/gnome.dconf

	echo "finished! now reboot your system"
}

install_extension() {
	for i in "$@"; do
		GN_SHELL=$(gnome-shell --version | cut -d' ' -f3 | cut -d'.' -f1)
		VERSION_TAG=$(curl -s "https://extensions.gnome.org/extension-query/?search=${i}" |
			jq -r '.extensions[] | select(.uuid=="'"${i}"'") | .shell_version_map | .["'"${GN_SHELL}"'"] | .pk')
		wget -qO "${i}.zip" "https://extensions.gnome.org/download-extension/${i}.shell-extension.zip?version_tag=$VERSION_TAG" &&
			gnome-extensions install --force "${i}.zip" &&
			rm "${i}.zip"
	done
}

setup_system
