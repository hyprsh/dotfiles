# my dotfiles

my dotfiles for macOS and fedora silverblue

## todos

- [ ] move from zsh to bash (darwin)
- [ ] config yt-dlp alias or find alternatives

## how to install
### darwin

```bash
git clone https://github.com/hyprsh/dotfiles $HOME/.dotfiles && cd $HOME/.dotfiles
./setup-darwin.sh
reboot
```

### fedora silverblue

```bash
git clone https://github.com/hyprsh/dotfiles $HOME/.dotfiles && cd $HOME/.dotfiles
./setup-silverblue.sh
reboot
```

current yt-dlp command:

```bash
yt-dlp --merge-output-format mp4 \ # needed for ipad files app
--format-sort res:720,fps,vcodec:h264,acodec:m4a \
--embed-thumbnail \
--add-metadata \
--embed-metadata \
--embed-chapters \
--windows-filenames \
--abort-on-error \
--output "%(title)+.100s - %(id)s.%(ext)s"
```
