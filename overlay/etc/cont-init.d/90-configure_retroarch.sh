#!bin/bash
set -e
echo "***Configure Retroarch****"
#echo "Disable Retroarch Autostart"
#sed -i 's|^autostart.*=.*$|autostart=false|' /etc/supervisor.d/retroarch.ini
#chmod +x /usr/bin/start-retroarch.sh
echo "Ensure proper Retroarch folder permissions"
#chmod -R a+rw /home/${USER}/.config/retroarch/
#chown -R ${PUID}:${PGID} /home/${USER}/.config/retroarch/
echo "Copy Retroarch config from template"
# cp -vf /templates/retroarch/* /home/default/.config/retroarch/
# # Copy pre-installed cores from the retroarch ppa
# cp -u /usr/lib/$(uname -m)-linux-gnu/libretro/* "/home/default/.config/retroarch/cores/"

# # if there are no assets, manually download them
# if [ ! -d "$CFG_DIR/assets" ]; then
    # wget -q --show-progress -P /tmp https://buildbot.libretro.com/assets/frontend/assets.zip
    # 7z x /tmp/assets.zip -bso0 -bse0 -bsp1 -o"/home/default/.config/retroarch/assets"
    # rm /tmp/assets.zip
# fi
echo "DONE"