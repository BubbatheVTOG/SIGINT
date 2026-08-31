#!/bin/sh
# Gradually dim the screen to 10% on idle. If already at or below 10%,
# do nothing and mark "skip" so screen-restore.sh leaves it alone.
# Invoked by hypridle on-timeout. The dim runs in the background so
# hypridle doesn't block; PID is tracked for early-cancel on resume.

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}"
STATE_FILE="$CACHE_DIR/screen-dim-state"
PID_FILE="$CACHE_DIR/screen-dim.pid"
TARGET_PCT=10
DIM_STEPS=8
DIM_DURATION=0.8

info=$(brightnessctl -m info)
cur=$(printf '%s' "$info" | cut -d, -f3)
max=$(printf '%s' "$info" | cut -d, -f5)
target=$((max * TARGET_PCT / 100))

if [ "$cur" -le "$target" ]; then
    printf 'skip' > "$STATE_FILE"
    exit 0
fi

printf '%s' "$cur" > "$STATE_FILE"

# Background the gradual dim; track PID for cancel on resume
(
    step_delay=$(awk "BEGIN{print $DIM_DURATION/$DIM_STEPS}")
    i=1
    while [ "$i" -le "$DIM_STEPS" ]; do
        level=$(awk "BEGIN{printf \"%d\", $cur + ($target - $cur) * $i / $DIM_STEPS}")
        brightnessctl -q set "$level"
        sleep "$step_delay"
        i=$((i + 1))
    done
    brightnessctl -q set "$target"
    rm -f "$PID_FILE"
) &

printf '%s' "$!" > "$PID_FILE"
