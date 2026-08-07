#!/usr/bin/env bash
# Theme Toggle Script for Hyprland, Waybar, Kitty, Rofi, Dunst, and OpenCode

THEME_FILE="$HOME/.cache/current_theme"

if [ -f "$THEME_FILE" ]; then
    CURRENT_THEME=$(cat "$THEME_FILE")
else
    CURRENT_THEME="teal"
fi

WAYBAR_CSS="$HOME/.config/waybar/style.css"
KITTY_CONF="$HOME/.config/kitty/kitty.conf"
ROFI_RASI="$HOME/.config/rofi/themes/black-neon.rasi"
OPENCODE_JSON="$HOME/.config/opencode/opencode.json"
HYPR_LUA="$HOME/.config/hypr/hyprland.lua"

if [ "$CURRENT_THEME" = "teal" ]; then
    NEW_THEME="red"
    echo "red" > "$THEME_FILE"

    # 1. Hyprland Borders (Update hyprland.lua on disk & reload)
    if [ -f "$HYPR_LUA" ]; then
        sed -i 's/rgba(33ccffee)/rgba(ef596fee)/g' "$HYPR_LUA"
        sed -i 's/rgba(00ff99ee)/rgba(d8985fee)/g' "$HYPR_LUA"
        sed -i 's/rgba(00FFFFEE)/rgba(ef596fee)/g' "$HYPR_LUA"
        hyprctl reload >/dev/null
    fi

    # 2. Waybar CSS Colors
    if [ -f "$WAYBAR_CSS" ]; then
        sed -i 's/@define-color teal #00ffff;/@define-color teal #ef596f;/g' "$WAYBAR_CSS"
        sed -i 's/@define-color teal-dim #00cccc;/@define-color teal-dim #c24038;/g' "$WAYBAR_CSS"
        sed -i 's/@define-color teal-light #00ffd5;/@define-color teal-light #d8985f;/g' "$WAYBAR_CSS"
        pkill -SIGUSR2 waybar
    fi

    # 3. Kitty Colors
    if [ -f "$KITTY_CONF" ]; then
        sed -i 's/#33ccff/#ef596f/g' "$KITTY_CONF"
        sed -i 's/#00ff99/#d8985f/g' "$KITTY_CONF"
        kill -SIGUSR1 $(pgrep kitty) 2>/dev/null
    fi

    # 4. Rofi Theme
    if [ -f "$ROFI_RASI" ]; then
        sed -i 's/#00ffff/#ef596f/g' "$ROFI_RASI"
    fi

    # 5. OpenCode Theme
    if [ -f "$OPENCODE_JSON" ]; then
        sed -i 's/"theme": "hyper-term-teal"/"theme": "hyper-term"/g' "$OPENCODE_JSON"
    fi

    notify-send "Theme Changed" "Switched to HyperTerm Red theme" -i preferences-desktop-theme
else
    NEW_THEME="teal"
    echo "teal" > "$THEME_FILE"

    # 1. Hyprland Borders (Update hyprland.lua on disk & reload)
    if [ -f "$HYPR_LUA" ]; then
        sed -i 's/rgba(ef596fee)/rgba(33ccffee)/g' "$HYPR_LUA"
        sed -i 's/rgba(d8985fee)/rgba(00ff99ee)/g' "$HYPR_LUA"
        sed -i 's/rgba(ef596fee)/rgba(33ccffee)/g' "$HYPR_LUA"
        hyprctl reload >/dev/null
    fi

    # 2. Waybar CSS Colors
    if [ -f "$WAYBAR_CSS" ]; then
        sed -i 's/@define-color teal #ef596f;/@define-color teal #00ffff;/g' "$WAYBAR_CSS"
        sed -i 's/@define-color teal-dim #c24038;/@define-color teal-dim #00cccc;/g' "$WAYBAR_CSS"
        sed -i 's/@define-color teal-light #d8985f;/@define-color teal-light #00ffd5;/g' "$WAYBAR_CSS"
        pkill -SIGUSR2 waybar
    fi

    # 3. Kitty Colors
    if [ -f "$KITTY_CONF" ]; then
        sed -i 's/#ef596f/#33ccff/g' "$KITTY_CONF"
        sed -i 's/#d8985f/#00ff99/g' "$KITTY_CONF"
        kill -SIGUSR1 $(pgrep kitty) 2>/dev/null
    fi

    # 4. Rofi Theme
    if [ -f "$ROFI_RASI" ]; then
        sed -i 's/#ef596f/#00ffff/g' "$ROFI_RASI"
    fi

    # 5. OpenCode Theme
    if [ -f "$OPENCODE_JSON" ]; then
        sed -i 's/"theme": "hyper-term"/"theme": "hyper-term-teal"/g' "$OPENCODE_JSON"
    fi

    notify-send "Theme Changed" "Switched to Teal theme" -i preferences-desktop-theme
fi
