#!/usr/bin/env sh

# copy settings files
cp $HOME/Library/Preferences/com.knollsoft.Hyperkey.plist ./hyperkey/com.knollsoft.Hyperkey.plist
cp $HOME/Library/Preferences/com.amethyst.Amethyst.plist ./amethyst/com.amethyst.Amethyst.plist

# generate bundlefile
brew bundle dump --global --force
cp $HOME/.Brewfile ./brew/Brewfile
