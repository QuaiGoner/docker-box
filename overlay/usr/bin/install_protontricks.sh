#!/usr/bin/env bash

echo "**** Installing Protontricks via flatpak ****"

# Install ProtonUp-Qt
flatpak --user remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo 
flatpak --user install --assumeyes flathub com.github.Matoking.protontricks

# Configure ProtonUp-Qt
echo "Configure ProtonUp-Qt..."
sed -i 's/^Categories=.*$/Categories=Utility;/' \
    ${USER_HOME}/.local/share/flatpak/exports/share/applications/net.davidotek.pupgui2.desktop

echo "DONE"
