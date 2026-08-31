#!/bin/sh
# Restore screen brightness on resume from idle dim.
# If screen-dim.sh marked "skip" or is still running, handle accordingly.
# Invoked by hypridle on-resume.

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}"
STATE_FILE="$CACHE_DIR/screen-dim-state"
PID_FILE="$CACHE_DIR/screen-dim.pid"

# Kill a dim still in progress
if [ -f "$PID_FILE" ]; then
    kill "$(cat "$PID_FILE")" 2>/dev/null
    rm -f "$PID_FILE"
fi

if [ ! -f "$STATE_FILE" ]; then
    exit 0
fi

saved=$(cat "$STATE_FILE")
rm -f "$STATE_FILE"

[ "$saved" = "skip" ] && exit 0

brightnessctl -q set "$saved"
