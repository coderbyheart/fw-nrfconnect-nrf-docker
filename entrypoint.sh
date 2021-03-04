#!/bin/bash
# Read in the file of environment settings
. /ncs/zephyr/zephyr-env.sh
# Then run the CMD
exec "$@"
