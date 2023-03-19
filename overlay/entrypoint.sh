#!/usr/bin/env bash
###
# File: entrypoint.sh
# Project: docker-box

set -e

# If a command was passed, run that instead of the usual init process
if [ ! -z "$@" ]; then
    exec $@
    exit $?
fi

# Print the current version (if the file exists)
if [[ -f /version.txt ]]; then
    cat /version.txt
fi

# Execute all container init scripts
for init_script in /etc/cont-init.d/*.sh ; do
    echo
    echo "[ ${init_script}: executing... ]"
    sed -i 's/\r$//' "${init_script}"
    source "${init_script}"
done

# Ensure all scripts are executable
chmod a+rwx /opt/scripts/*.sh
chmod a+rwx /usr/bin/*.sh

echo "***Configure Retroarch****"
chmod +x /usr/bin/start-retroarch.sh

echo "Ensure proper Retroarch folder permissions"
mkdir -p /home/${USER}/.config/retroarch/
chmod -R a+rw /home/${USER}/.config/retroarch/
chown -R ${PUID}:${PGID} /home/${USER}/.config/retroarch/

echo "Copy Retroarch config from template"
 cp -vf /templates/retroarch/* /home/default/.config/retroarch/

echo  "Copy pre-installed cores from the retroarch ppa"
mkdir -p /home/${USER}/.config/retroarch/cores/
cp -u /usr/lib/$(uname -m)-linux-gnu/libretro/* "/home/${USER}/.config/retroarch/cores/"

echo  "Manually download assets"
 if [ ! -d "/home/${USER}/.config/retroarch/assets" ]; then
	wget -q -P /tmp https://buildbot.libretro.com/assets/frontend/assets.zip
	echo "extracting assets"
	unzip /tmp/assets.zip -d /home/default/.config/retroarch/assets
	rm /tmp/assets.zip
 fi

echo "Retroarch Configured"

# Start supervisord
echo
echo "**** Starting supervisord ****";
echo "Logging all root services to '/var/log/supervisor/'"
echo "Logging all user services to '/home/${USER}/.cache/log/'"
echo
mkdir -p /var/log/supervisor
chmod a+rw /var/log/supervisor
exec /usr/bin/supervisord -c /etc/supervisord.conf --nodaemon --user root
