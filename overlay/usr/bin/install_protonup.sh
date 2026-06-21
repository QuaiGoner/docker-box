#!/usr/bin/env bash

echo "**** Installing ProtonUp-Qt via flatpak ****"

# Install ProtonUp-Qt
flatpak --user remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo 
flatpak --user install --assumeyes net.davidotek.pupgui2

# Configure ProtonUp-Qt
echo "Configure ProtonUp-Qt..."
sed -i 's/^Categories=.*$/Categories=Utility;/' \
    ${USER_HOME}/.local/share/flatpak/exports/share/applications/net.davidotek.pupgui2.desktop

echo "DONE"
