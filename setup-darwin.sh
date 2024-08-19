#!/usr/bin/env sh

SRC="$(pwd)/config"
DST="$HOME/.config"

link() {
    rm -r $DST/"$1"
    ln -s $SRC/"$1" $DST/"$1"
}

# links to iCloudDrive
rm -r $HOME/iCloud
ln -s "$HOME/Library/Mobile Documents/com~apple~CloudDocs" "$HOME/iCloud"

link aerospace
link bat
bat cache --build
link git
link nvim
link tmux
link alacritty
link yt-dlp
link zsh

# install brew if not installed
if type brew &>/dev/null; then
 NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# brew
rm $HOME/.Brewfile
cp $DOTFILES/brew/Brewfile $HOME/.Brewfile
link brew

# hyperkey
rm $HOME/Library/Preferences/com.knollsoft.Hyperkey.plist
cp $DOTFILES/hyperkey/com.knollsoft.Hyperkey.plist $HOME/Library/Preferences/com.knollsoft.Hyperkey.plist

# scripts
mkdir -p $HOME/.local/bin
ln -sf scripts/t.sh $HOME/.local/bin/t

# monolisa font
cp fonts/monolisa/* $HOME/Library/Fonts


# install software from bundlefile
brew bundle --global --no-lock
