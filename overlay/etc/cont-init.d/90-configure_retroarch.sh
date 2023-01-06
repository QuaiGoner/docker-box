#!bin/bash
set -e
echo "***Configture Retroarch****"
echo "Disable Retroarch Autostart"
sed -i 's|^autostart.*=.*$|autostart=false|' /etc/supervisor.d/retroarch.ini
chmod +x /usr/bin/start-retroarch.sh
echo "Ensure proper Retroarch folder permissions"
chmod -R a+rw /home/${USER}/.config/retroarch/
chown -R ${PUID}:${PGID} /home/${USER}/.config/retroarch/
echo "DONE"