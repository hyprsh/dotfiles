
#!/bin/bash

distrobox-create --image registry.fedoraproject.org/fedora-toolbox:40 --name code -Y
distrobox-create --unshare-netns --image ghcr.io/ublue-os/bazzite-arch-gnome --name gaming -Y
