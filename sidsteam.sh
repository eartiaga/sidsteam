#!/bin/bash

# Create a symbolic link to this file from the $PATH and invoke as:
#   sidsteam.sh </path/to/local/steam/data/directory>
#
# set the environment variable STEAM_ACTION to
#   - "custom" to simply skip steam and execute local launch.rc scripts
#   - "shell" to skip steam and get a bash shell
#   - "wait" to skip steam and leave the container on stand-by

BINDIR=$(dirname "$(readlink -f "$0")")
export STEAM_DATADIR="$1"
STEAM_UID=$(id -ru)
export STEAM_UID
shift

if [ -z "$STEAM_DATADIR" ] || [ ! -d "$STEAM_DATADIR" ]; then
    echo "Usage: $(basename "$0") </path/to/local/steam/data/directory>"
    echo "ERROR: Missing or invalid steam directory path: \"$STEAM_DATADIR\""
    exit 1
fi

echo "Launching Sid Steam Docker from: $BINDIR"
echo "- User: $STEAM_UID ($(id -un "$STEAM_UID"))"
echo "- Data: $STEAM_DATADIR"

(cd "$BINDIR" && docker compose --verbose up)

