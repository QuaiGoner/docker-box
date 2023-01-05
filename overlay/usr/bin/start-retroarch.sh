#!/usr/bin/env bash
###
set -e
source /usr/bin/common-functions.sh

# CATCH TERM SIGNAL:
_term() {
    kill -TERM "$retroarch_pid" 2>/dev/null
}
trap _term SIGTERM SIGINT

# CONFIGURE:
# Install default configurations
if [[ ! -f /home/default/.config/retroarch/retroarch.cfg ]]; then
    cp -vf /templates/retroarch/* /home/default/.config/retroarch/
fi

# EXECUTE PROCESS:
# Wait for the X server to start
wait_for_x
# Start the retroarch
retroarch --fullscreen &
retroarch_pid=$!


# WAIT FOR CHILD PROCESS:
wait "$retroarch_pid"
