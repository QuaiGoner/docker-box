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

# Start supervisord
echo
echo "**** Starting supervisord ****";
echo "Logging all root services to '/var/log/supervisor/'"
echo "Logging all user services to '/home/${USER}/.cache/log/'"
echo
mkdir -p /var/log/supervisor
chmod a+rw /var/log/supervisor
exec /usr/bin/supervisord -c /etc/supervisord.conf --nodaemon --user root
exec /usr/bin/emulationstation
