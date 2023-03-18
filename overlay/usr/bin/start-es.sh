#!/usr/bin/env bash
###
# File: start-sunshine.sh
# Project: bin
# File Created: Tuesday, 4th October 2022 8:22:17 pm
# Author: Josh.5 (jsunnex@gmail.com)
# -----
# Last Modified: Tuesday, 4th October 2022 8:22:17 pm
# Modified By: Josh.5 (jsunnex@gmail.com)
###
set -e
source /usr/bin/common-functions.sh

# CATCH TERM SIGNAL:
_term() {
    kill -TERM "$es_pid" 2>/dev/null
}
trap _term SIGTERM SIGINT


# EXECUTE PROCESS:
# Wait for the X server to start
wait_for_x
# Start the es
sleep 5
exec /usr/bin/emulationstation
