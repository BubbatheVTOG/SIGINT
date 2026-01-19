#!/bin/bash

# Lid handler script for Hyprland
# Usage: lid_handler.sh [close|open]

# Configuration
LOCK_TIMEOUT=60  # seconds to wait before turning off screen
PID_FILE="/tmp/hyprland_lid_screen_off.pid"

# Function to start screen off timer
start_screen_timer() {
    # Kill any existing timer
    kill_screen_timer
    
    # Start new timer in background
    (
        sleep $LOCK_TIMEOUT
        # Only turn off screen if hyprlock is still running
        if pidof hyprlock >/dev/null; then
            hyprctl dispatch dpms off
        fi
    ) &
    
    # Store PID for later cancellation
    echo $! > "$PID_FILE"
}

# Function to kill existing timer
kill_screen_timer() {
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if kill -0 "$PID" 2>/dev/null; then
            kill "$PID" 2>/dev/null
        fi
        rm -f "$PID_FILE"
    fi
}

case "$1" in
    "close")
        # Immediately lock the screen
        pidof hyprlock || hyprlock &
        
        # Start timer to turn off screen after LOCK_TIMEOUT seconds
        start_screen_timer
        ;;
    "open")
        # Kill the screen off timer
        kill_screen_timer
        
        # Turn screen back on
        hyprctl dispatch dpms on
        
        # Optional: You can add commands here to handle monitor re-enabling
        # hyprctl keyword monitor "eDP-1,preferred,auto,1"
        ;;
    *)
        echo "Usage: $0 [close|open]"
        exit 1
        ;;
esac