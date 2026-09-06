#!/bin/sh
# Gradually dim the screen to 10% on idle using a gamma-corrected
# (perceptually linear) brightness ramp. If already at or below 10%,
# do nothing and mark "skip" so screen-restore.sh leaves it alone.
# Invoked by hypridle on-timeout. The dim runs in the background so
# hypridle doesn't block; PID is tracked for early-cancel on resume.

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}"
STATE_FILE="$CACHE_DIR/screen-dim-state"
PID_FILE="$CACHE_DIR/screen-dim.pid"
TARGET_PCT=10
DIM_STEPS=30
DIM_DURATION=0.8
GAMMA=2.2

mkdir -p "$CACHE_DIR" 2>/dev/null || {
    echo "screen-dim: cannot create $CACHE_DIR" >&2
    exit 1
}

# Validate tunables (guards against latent divide-by-zero and nan ramps)
[ "$DIM_STEPS" -ge 1 ] 2>/dev/null || DIM_STEPS=1
awk "BEGIN{exit !($GAMMA > 0)}" || GAMMA=2.2

info=$(brightnessctl -m info) || {
    echo "screen-dim: brightnessctl info failed" >&2
    exit 1
}
cur=$(printf '%s' "$info" | cut -d, -f3)
max=$(printf '%s' "$info" | cut -d, -f5)

# Validate parsed values: both must be non-empty integers, max > 0
case "$cur" in '' | *[!0-9]*) echo "screen-dim: bad current brightness '$cur'" >&2; exit 1 ;; esac
case "$max" in '' | *[!0-9]*) echo "screen-dim: bad max brightness '$max'" >&2; exit 1 ;; esac
[ "$max" -gt 0 ] || { echo "screen-dim: max brightness is 0" >&2; exit 1; }

target=$((max * TARGET_PCT / 100))

if [ "$cur" -le "$target" ]; then
    printf 'skip' > "$STATE_FILE"
    exit 0
fi

printf '%s' "$cur" > "$STATE_FILE"

# Background the gradual dim; track PID for cancel on resume.
# Ramp in perceived-brightness space: P(x) = (x/max)^(1/gamma), so a
# linear sweep of P produces an even perceived fade. Convert each step
# back to raw sysfs units with x = max * P^gamma.
(
    step_delay=$(awk "BEGIN{print $DIM_DURATION/$DIM_STEPS}")
    pcur=$(awk "BEGIN{printf \"%.6f\", ($cur/$max)^(1/$GAMMA)}")
    ptgt=$(awk "BEGIN{printf \"%.6f\", ($target/$max)^(1/$GAMMA)}")
    i=1
    while [ "$i" -le "$DIM_STEPS" ]; do
        level=$(awk "BEGIN{printf \"%d\", $max * ($pcur + ($ptgt - $pcur) * $i / $DIM_STEPS)^$GAMMA}")
        brightnessctl -q set "$level"
        sleep "$step_delay"
        i=$((i + 1))
    done
    brightnessctl -q set "$target"
    rm -f "$PID_FILE"
) &

printf '%s' "$!" > "$PID_FILE"
