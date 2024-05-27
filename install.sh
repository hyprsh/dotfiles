#!/usr/bin/env sh

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# amethyst
rm ~/Library/Preferences/com.amethyst.Amethyst.plist
cp $DOTFILES/amethyst/com.amethyst.Amethyst.plist $HOME/Library/Preferences/com.amethyst.Amethyst.plist

# bat
mkdir -p $HOME/.config/bat/themes
curl https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras/sublime/tokyonight_storm.tmTheme -o $HOME/.config/bat/themes/tokyonight_storm.tmTheme
curl https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras/sublime/tokyonight_day.tmTheme -o $HOME/.config/bat/themes/tokyonight_day.tmTheme
bat cache --build
bat --list-themes | grep tokyo # should output "tokyonight_night"
echo '--theme="tokyonight_storm"' >> "$HOME/.config/bat/config"

# brew
rm -rf $HOME/.Brewfile
cp $DOTFILES/brew/Brewfile $HOME/.Brewfile
rm -rf $HOME/.config/homebrew/brew.env
mkdir -p $HOME/.config/homebrew
ln -s $DOTFILES/brew/brew.env $HOME/.config/homebrew/brew.env

# git
rm -rf $HOME/.gitconfig
mkdir -p $HOME/.config/git
ln -s $DOTFILES/git/gitconfig $HOME/.gitconfig

# hyperkey
rm -rf $HOME/Library/Preferences/com.knollsoft.Hyperkey.plist
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

# zsh
rm -rf $HOME/.zshrc
ln -s $DOTFILES/zsh/zshrc $HOME/.zshrc

# install brew if not installed
if type brew &>/dev/null; then
 NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# install software from bundlefile
brew bundle --global --no-lock
