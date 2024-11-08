#!/usr/bin/env sh

ROOT="$(pwd)"
SRC="$(pwd)/config"
DST="$HOME/.config"

# links to iCloudDrive
rm -r $HOME/iCloud
ln -s "$HOME/Library/Mobile Documents/com~apple~CloudDocs" "$HOME/iCloud"

rm -f $HOME/.bashrc && ln -s $SRC/bash/bashrc $HOME/.bashrc
rm -f $HOME/.inputrc && ln -s $SRC/bash/inputrc $HOME/.inputrc
rm -f $HOME/.zshrc && ln -s $SRC/zsh/zshrc $HOME/.zshrc # TODO:  migrate to bash
ln -s $SRC/tmux $DST/tmux
ln -s $SRC/wezterm $DST/wezterm
ln -s $SRC/git $DST/git
ln -s $SRC/nvim $DST/nvim
ln -s $SRC/skhd $DST/skhd

# install brew
if type brew &>/dev/null; then
 NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# cli tools
brew install bat btop eza fd fzf gh neovim procs ripgrep tealdeer \
    tmux trash-cli yq jq zoxide lazygit ffmpeg skhd zf mas

# apps
brew install --cask betterdisplay wezterm discord zen-browser steam

# appstore apps
mas install 1352778147 # bitwarden
mas install 1592917505 # noir
mas install 1429033973 # runcat
mas install 1451685025 # wireguard

# scripts
# mkdir -p $HOME/.local/bin
# cp scripts/* $HOME/.local/bin

# install fonts
cp fonts/* $HOME/Library/Fonts
