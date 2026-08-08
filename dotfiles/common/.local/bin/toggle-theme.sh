#!/usr/bin/env bash
# Theme Toggle Script for Hyprland, Waybar, Kitty, Rofi, Dunst, Tmux, and Hyprpaper Wallpaper

THEME_FILE="$HOME/.cache/current_theme"

if [ -f "$THEME_FILE" ]; then
    CURRENT_THEME=$(cat "$THEME_FILE")
else
    CURRENT_THEME="teal"
fi

WAYBAR_CSS="$HOME/.config/waybar/style.css"
KITTY_CONF="$HOME/.config/kitty/kitty.conf"
ROFI_RASI="$HOME/.config/rofi/themes/black-neon.rasi"
TMUX_CONF="$HOME/.tmux.conf"
HYPR_LUA="$HOME/.config/hypr/hyprland.lua"
HYPRPAPER_CONF="$HOME/.config/hypr/hyprpaper.conf"

if [ "$CURRENT_THEME" = "teal" ]; then
    NEW_THEME="red"
    echo "red" > "$THEME_FILE"

    # 1. Hyprland Borders
    if [ -f "$HYPR_LUA" ]; then
        sed --follow-symlinks -i 's/rgba(33ccffee)/rgba(ef596fee)/g' "$HYPR_LUA"
        sed --follow-symlinks -i 's/rgba(00ff99ee)/rgba(d8985fee)/g' "$HYPR_LUA"
        hyprctl reload >/dev/null
    fi

    # 2. Waybar CSS Colors
    if [ -f "$WAYBAR_CSS" ]; then
        sed --follow-symlinks -i 's/@define-color teal #00ffff;/@define-color teal #ef596f;/g' "$WAYBAR_CSS"
        sed --follow-symlinks -i 's/@define-color teal-dim #00cccc;/@define-color teal-dim #c24038;/g' "$WAYBAR_CSS"
        sed --follow-symlinks -i 's/@define-color teal-light #00ffd5;/@define-color teal-light #d8985f;/g' "$WAYBAR_CSS"
        pkill -SIGUSR2 waybar
    fi

    # 3. Kitty Colors
    if [ -f "$KITTY_CONF" ]; then
        sed --follow-symlinks -i 's/#33ccff/#ef596f/g' "$KITTY_CONF"
        sed --follow-symlinks -i 's/#00ff99/#d8985f/g' "$KITTY_CONF"
        kill -SIGUSR1 $(pgrep kitty) 2>/dev/null
    fi

    # 4. Rofi Theme
    if [ -f "$ROFI_RASI" ]; then
        sed --follow-symlinks -i 's/#00ffff/#ef596f/g' "$ROFI_RASI"
    fi

    # 5. Tmux Status Color
    if [ -f "$TMUX_CONF" ]; then
        sed --follow-symlinks -i 's/#33ccff/#ef596f/g' "$TMUX_CONF"
        tmux source-file "$TMUX_CONF" 2>/dev/null
    fi

    # 6. Hyprpaper Wallpaper
    if [ -f "$HYPRPAPER_CONF" ]; then
        sed --follow-symlinks -i "s|$HOME/.config/hypr/wallpapers/teal.jpg|$HOME/.config/hypr/wallpapers/red.jpg|g" "$HYPRPAPER_CONF"
        pkill hyprpaper
        hyprpaper >/dev/null 2>&1 &
    fi

    notify-send "Theme Changed" "Switched to HyperTerm Red theme" -i preferences-desktop-theme
else
    NEW_THEME="teal"
    echo "teal" > "$THEME_FILE"

    # 1. Hyprland Borders
    if [ -f "$HYPR_LUA" ]; then
        sed --follow-symlinks -i 's/rgba(ef596fee)/rgba(33ccffee)/g' "$HYPR_LUA"
        sed --follow-symlinks -i 's/rgba(d8985fee)/rgba(00ff99ee)/g' "$HYPR_LUA"
        hyprctl reload >/dev/null
    fi

    # 2. Waybar CSS Colors
    if [ -f "$WAYBAR_CSS" ]; then
        sed --follow-symlinks -i 's/@define-color teal #ef596f;/@define-color teal #00ffff;/g' "$WAYBAR_CSS"
        sed --follow-symlinks -i 's/@define-color teal-dim #c24038;/@define-color teal-dim #00cccc;/g' "$WAYBAR_CSS"
        sed --follow-symlinks -i 's/@define-color teal-light #d8985f;/@define-color teal-light #00ffd5;/g' "$WAYBAR_CSS"
        pkill -SIGUSR2 waybar
    fi

    # 3. Kitty Colors
    if [ -f "$KITTY_CONF" ]; then
        sed --follow-symlinks -i 's/#ef596f/#33ccff/g' "$KITTY_CONF"
        sed --follow-symlinks -i 's/#d8985f/#00ff99/g' "$KITTY_CONF"
        kill -SIGUSR1 $(pgrep kitty) 2>/dev/null
    fi

    # 4. Rofi Theme
    if [ -f "$ROFI_RASI" ]; then
        sed --follow-symlinks -i 's/#ef596f/#00ffff/g' "$ROFI_RASI"
    fi

    # 5. Tmux Status Color
    if [ -f "$TMUX_CONF" ]; then
        sed --follow-symlinks -i 's/#ef596f/#33ccff/g' "$TMUX_CONF"
        tmux source-file "$TMUX_CONF" 2>/dev/null
    fi

    # 6. Hyprpaper Wallpaper
    if [ -f "$HYPRPAPER_CONF" ]; then
        sed --follow-symlinks -i "s|$HOME/.config/hypr/wallpapers/red.jpg|$HOME/.config/hypr/wallpapers/teal.jpg|g" "$HYPRPAPER_CONF"
        pkill hyprpaper
        hyprpaper >/dev/null 2>&1 &
    fi

    notify-send "Theme Changed" "Switched to Teal theme" -i preferences-desktop-theme
fi
