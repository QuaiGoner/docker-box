#!bin/bash
set -e

echo "***Configure Retroarch****"
#echo "Disable Retroarch Autostart"
#sed -i 's|^autostart.*=.*$|autostart=false|' /etc/supervisor.d/retroarch.ini
#chmod +x /usr/bin/start-retroarch.sh

echo "Ensure proper Retroarch folder permissions"
mkdir -p /home/${USER}/.config/retroarch/assets
chmod -R a+rw /home/${USER}/.config/retroarch/
chown -R ${PUID}:${PGID} /home/${USER}/.config/retroarch/

echo "Copy Retroarch config from template"
 cp -vf /templates/retroarch/* /home/default/.config/retroarch/

echo  "Copy pre-installed cores from the retroarch ppa"
mkdir -p /home/${USER}/.config/retroarch/cores/
cp -u /usr/lib/$(uname -m)-linux-gnu/libretro/* "/home/${USER}/.config/retroarch/cores/"

echo  "if there are no assets, manually download them"
 if [ ! -d "/home/${USER}/.config/retroarch/assets" ]; then
     wget -q -P /tmp https://buildbot.libretro.com/assets/frontend/assets.zip
     7z x /tmp/assets.zip -bso0 -bse0 -bsp1 -o"/home/${USER}/.config/retroarch/assets"
     rm /tmp/assets.zip
 fi
echo "DONE"