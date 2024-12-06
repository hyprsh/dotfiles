#!/usr/bin/env sh

ROOT="$(pwd)"
SRC="$(pwd)/config"
DST="$HOME/.config"

# link icloud
ln -s "$HOME/Library/Mobile Documents/com~apple~CloudDocs" "$HOME/iCloud"

# link configs
rm -f $HOME/.zshrc && ln -s $SRC/zsh/zshrc $HOME/.zshrc
rm -f $HOME/.gitconfig && ln -s $SRC/git/gitconfig $HOME/.gitconfig
ln -s $SRC/tmux $DST/tmux
ln -s $SRC/wezterm $DST/wezterm
ln -s $SRC/git $DST/git
ln -s $SRC/nvim $DST/nvim

# install brew
if type brew 2>&1 >/dev/null; then
	NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# formulas
brew install btop fd fzf gh neovim ripgrep tmux trash-cli jq zoxide lazygit ffmpeg mas yt-dlp git-credential-manager asdf

# casks
brew install --cask betterdisplay wezterm font-iosevka bettertouchtool

# appstore apps
mas install 1592917505 # noir
mas install 1429033973 # runcat
mas install 1451685025 # wireguard
