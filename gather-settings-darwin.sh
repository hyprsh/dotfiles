#!/usr/bin/env sh

# generate bundlefile
brew bundle dump --global --force
cp $HOME/.Brewfile config/brew/Brewfile
