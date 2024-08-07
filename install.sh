#!/usr/bin/env sh

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# links to iCloudDrive
rm -r $HOME/iCloud
ln -s "$HOME/Library/Mobile Documents/com~apple~CloudDocs" "$HOME/iCloud"

# aerospace
rm -rf $HOME/.config/aerospace
ln -s $DOTFILES/aerospace $HOME/.config/aerospace

# bat
mkdir -p $HOME/.config/bat/themes
curl https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras/sublime/tokyonight_storm.tmTheme -o $HOME/.config/bat/themes/tokyonight_storm.tmTheme
curl https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras/sublime/tokyonight_day.tmTheme -o $HOME/.config/bat/themes/tokyonight_day.tmTheme
bat cache --build
echo '--theme="tokyonight_storm"' >> "$HOME/.config/bat/config"

# brew
rm $HOME/.Brewfile
cp $DOTFILES/brew/Brewfile $HOME/.Brewfile
rm $HOME/.config/homebrew/brew.env
mkdir -p $HOME/.config/homebrew
ln -s $DOTFILES/brew/brew.env $HOME/.config/homebrew/brew.env

# git
rm -rf $HOME/.gitconfig
ln -s $DOTFILES/git/gitconfig $HOME/.gitconfig

# hyperkey
rm $HOME/Library/Preferences/com.knollsoft.Hyperkey.plist
cp $DOTFILES/hyperkey/com.knollsoft.Hyperkey.plist $HOME/Library/Preferences/com.knollsoft.Hyperkey.plist

# nvim
rm -rf $HOME/.config/nvim
ln -s $DOTFILES/nvim $HOME/.config/nvim

# scripts
mkdir -p $HOME/.local/bin
ln -sf $DOTFILES/scripts/t.sh $HOME/.local/bin/t

# tmux
rm -rf $HOME/.config/tmux
ln -s $DOTFILES/tmux/ $HOME/.config/tmux

# wezterm
rm -rf $HOME/.config/wezterm
ln -s $DOTFILES/wezterm $HOME/.config/wezterm

# yt-dlp
rm -rf $HOME/.config/yt-dlp
ln -s $DOTFILES/yt-dlp $HOME/.config/yt-dlp

# zsh
rm -rf $HOME/.zshrc
ln -s $DOTFILES/zsh/zshrc $HOME/.zshrc

# monolisa font
cp $DOTFILES/fonts/monolisa/* $HOME/Library/Fonts

# install brew if not installed
if type brew &>/dev/null; then
 NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# install software from bundlefile
brew bundle --global --no-lock
