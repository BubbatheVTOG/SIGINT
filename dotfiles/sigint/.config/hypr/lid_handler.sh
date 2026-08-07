#!/bin/bash

# Lid handler script for Hyprland
# Usage: lid_handler.sh [close|open]
# Note: hypridle handles screen-off-after-lock via its own listeners,
#       so this script only triggers the lock and restores DPMS on open.

case "$1" in
    "close")
        # Immediately lock the screen (hypridle's lock_cmd avoids duplicates)
        pidof hyprlock || hyprlock
        ;;
    "open")
        # Turn screen back on (hypridle's on-resume handles the idle case)
        hyprctl dispatch dpms on
        ;;
    *)
        echo "Usage: $0 [close|open]"
        exit 1
        ;;
esac