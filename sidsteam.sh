#!/bin/bash

# Create a symbolic link to this file from the $PATH and invoke as:
#   sidsteam.sh </path/to/local/steam/data/directory>

BINDIR=$(dirname "$(readlink -f "$0")")
export STEAM_DATADIR="$1"
export STEAM_UID=$(id -ru)

if [ -z "$STEAM_DATADIR" -o ! -d "$STEAM_DATADIR" ]; then
    echo "Usage: $(basename "$0") </path/to/local/steam/data/directory>"
    echo "ERROR: Missing or invalid steam directory path: \"$STEAM_DATADIR\""
    exit 1
fi

echo "Launching Sid Steam Docker from: $BINDIR"
echo "- User: $STEAM_UID ($(id -un $STEAM_UID))"
echo "- Data: $STEAM_DATADIR"

(cd $BINDIR && docker-compose up)

