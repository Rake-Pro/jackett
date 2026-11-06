#!/bin/sh
# Data lives in /config/Jackett (same layout as the previous image).
exec /app/bin/jackett --NoUpdates --ListenPublic --DataFolder /config/Jackett "$@"
