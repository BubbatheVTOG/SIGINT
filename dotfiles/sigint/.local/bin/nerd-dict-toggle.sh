#!/usr/bin/env bash
# nerd-dictation toggle for Hyprland SUPER+M (start / stop speech-to-text).
# Mirrors matt's `voxtype record toggle` on this host.
#
# nerd-dictation has no built-in toggle. The --cookie file doubles as the
# running-state bit: `begin` creates it with mtime 0; `end` only touches it
# (bumps mtime, cookie persists). So:
#   cookie missing                -> start recording
#   cookie present, mtime == 0    -> stop recording (commit text)
#   cookie present, mtime != 0    -> restart recording (was ended before)
set -euo pipefail

COOKIE="${NERD_DICTATION_COOKIE:-/tmp/nerd-dictation-cookie}"
ND="/home/bubba/.local/bin/nerd-dictation"

if [ -e "$COOKIE" ] && [ "$(stat -c %Y "$COOKIE" 2>/dev/null || echo 1)" -eq 0 ]; then
    exec "$ND" end --cookie="$COOKIE"
else
    exec "$ND" begin --cookie="$COOKIE" --simulate-input-tool=WTYPE
fi