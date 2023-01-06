#!bin/bash
set -e
echo "***Configture Retroarch****"
echo "Enable Retroarch Autostart"
sed -i 's|^autostart.*=.*$|autostart=true|' /etc/supervisor.d/retroarch.ini
chmod +x /usr/bin/start-retroarch.sh
chmod -R a+rw /home/${USER}/.config/retroarch/
chown -R ${PUID}:${PGID} /home/${USER}/.config/retroarch/
echo "DONE"