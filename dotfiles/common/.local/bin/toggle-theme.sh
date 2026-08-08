#!/usr/bin/env bash
# Theme Toggle Script — cycles 6 themes via array-driven sed replacements.
#
# Affected: Hyprland borders, Waybar CSS, Kitty, Rofi, Tmux, Hyprpaper
#           wallpaper, Hyprlock, Fastfetch palette.
#
# Cycle: teal → red → green → yellow → orange → purple → teal → ...
# State: ~/.cache/current_theme (theme name string).
#
# All color values are defined in indexed arrays below — one entry per theme
# in cycle order.  Adding a theme = append one element to every array.

THEME_FILE="$HOME/.cache/current_theme"

# --- Theme cycle order (index = position in this list) ---
THEMES=(teal red green yellow orange purple)
declare -A IDX=( [teal]=0 [red]=1 [green]=2 [yellow]=3 [orange]=4 [purple]=5 )

# --- Color palettes (6 values each, one per theme index) ---
# Hex primary (#33ccff family) — kitty cursor/border/tab/ANSI, tmux status
H_PRI=("#33ccff" "#ef596f" "#33ff55" "#ffdd00" "#ff8833" "#bd00ff")
# Hex cyan variant (#00ffff family) — rofi foreground, waybar @teal, fastfetch
HC_PRI=("#00ffff" "#ef596f" "#33ff55" "#ffdd00" "#ff8833" "#bd00ff")
# Hex secondary (#00ff99 family) — kitty selection_background, url_color
H_SEC=("#00ff99" "#d8985f" "#88ff44" "#ffee44" "#ffbb66" "#d65fff")
# Hex dim (#00cccc family) — waybar @teal-dim, fastfetch separator
H_DIM=("#00cccc" "#c24038" "#33bb44" "#ccaa00" "#cc7722" "#9900cc")
# rgba hex primary — hyprland active_border[0]
R_PRI=("rgba(33ccffee)" "rgba(ef596fee)" "rgba(33ff55ee)" "rgba(ffdd00ee)" "rgba(ff8833ee)" "rgba(bd00ffee)")
# rgba hex secondary — hyprland active_border[1]
R_SEC=("rgba(00ff99ee)" "rgba(d8985fee)" "rgba(88ff44ee)" "rgba(ffee44ee)" "rgba(ffbb66ee)" "rgba(d65ffeee)")
# rgba hex dim — hyprland inactive_border
R_DIM=("rgba(00FFFFEE)" "rgba(c24038EE)" "rgba(33bb44EE)" "rgba(ccaa00EE)" "rgba(cc7722EE)" "rgba(9900ccEE)")
# Decimal RGB triple — hyprlock + waybar hardcoded rgba (alpha preserved)
D_RGB=("0, 255, 255" "239, 89, 111" "51, 255, 85" "255, 221, 0" "255, 136, 51" "189, 0, 255")
# Wallpaper filenames (in ~/.config/hypr/wallpapers/)
WP=(teal.jpg red.jpg green.jpg yellow.jpg orange.jpg purple.jpg)

# --- Config file paths ---
WAYBAR_CSS="$HOME/.config/waybar/style.css"
KITTY_CONF="$HOME/.config/kitty/kitty.conf"
ROFI_RASI="$HOME/.config/rofi/themes/black-neon.rasi"
TMUX_CONF="$HOME/.tmux.conf"
HYPR_LUA="$HOME/.config/hypr/hyprland.lua"
HYPRPAPER_CONF="$HOME/.config/hypr/hyprpaper.conf"
HYPRLOCK_CONF="$HOME/.config/hypr/hyprlock.conf"
PALETTE_FILE="$HOME/.config/theme/fastfetch-palette.sh"

# --- Determine current and next theme ---
if [ -f "$THEME_FILE" ]; then
    CURRENT_THEME=$(cat "$THEME_FILE")
else
    CURRENT_THEME="teal"
fi

current_idx=${IDX[$CURRENT_THEME]:-0}
new_idx=$(( (current_idx + 1) % ${#THEMES[@]} ))
NEW_THEME=${THEMES[$new_idx]}

echo "$NEW_THEME" > "$THEME_FILE"

# --- Apply replacements (no branching — pure array lookups) ---

# 1. Hyprland borders
if [ -f "$HYPR_LUA" ]; then
    sed --follow-symlinks -i "s/${R_PRI[$current_idx]}/${R_PRI[$new_idx]}/g" "$HYPR_LUA"
    sed --follow-symlinks -i "s/${R_SEC[$current_idx]}/${R_SEC[$new_idx]}/g" "$HYPR_LUA"
    sed --follow-symlinks -i "s/${R_DIM[$current_idx]}/${R_DIM[$new_idx]}/g" "$HYPR_LUA"
    hyprctl reload >/dev/null
fi

# 2. Waybar CSS — @define-color swaps + hardcoded rgba fix
if [ -f "$WAYBAR_CSS" ]; then
    sed --follow-symlinks -i "s/@define-color teal ${HC_PRI[$current_idx]};/@define-color teal ${HC_PRI[$new_idx]};/g" "$WAYBAR_CSS"
    sed --follow-symlinks -i "s/@define-color teal-dim ${H_DIM[$current_idx]};/@define-color teal-dim ${H_DIM[$new_idx]};/g" "$WAYBAR_CSS"
    sed --follow-symlinks -i "s/rgba(${D_RGB[$current_idx]}, /rgba(${D_RGB[$new_idx]}, /g" "$WAYBAR_CSS"
    pkill -SIGUSR2 waybar
fi

# 3. Kitty colors
if [ -f "$KITTY_CONF" ]; then
    sed --follow-symlinks -i "s/${H_PRI[$current_idx]}/${H_PRI[$new_idx]}/g" "$KITTY_CONF"
    sed --follow-symlinks -i "s/${H_SEC[$current_idx]}/${H_SEC[$new_idx]}/g" "$KITTY_CONF"
    kill -SIGUSR1 $(pgrep kitty) 2>/dev/null
fi

# 4. Rofi theme
if [ -f "$ROFI_RASI" ]; then
    sed --follow-symlinks -i "s/${HC_PRI[$current_idx]}/${HC_PRI[$new_idx]}/g" "$ROFI_RASI"
fi

# 5. Tmux status bar
if [ -f "$TMUX_CONF" ]; then
    sed --follow-symlinks -i "s/${H_PRI[$current_idx]}/${H_PRI[$new_idx]}/g" "$TMUX_CONF"
    tmux source-file "$TMUX_CONF" 2>/dev/null
fi

# 6. Hyprpaper wallpaper
if [ -f "$HYPRPAPER_CONF" ]; then
    sed --follow-symlinks -i "s|$HOME/.config/hypr/wallpapers/${WP[$current_idx]}|$HOME/.config/hypr/wallpapers/${WP[$new_idx]}|g" "$HYPRPAPER_CONF"
    pkill hyprpaper
    hyprpaper >/dev/null 2>&1 &
fi

# 7. Hyprlock colors
if [ -f "$HYPRLOCK_CONF" ]; then
    sed --follow-symlinks -i "s/rgba(${D_RGB[$current_idx]}, /rgba(${D_RGB[$new_idx]}, /g" "$HYPRLOCK_CONF"
fi

# 8. Fastfetch palette file
mkdir -p "$(dirname "$PALETTE_FILE")"
cat > "$PALETTE_FILE" <<EOF
# Fastfetch color palette — rewritten by toggle-theme.sh on every theme switch.
# Sourced by ~/.zshrc.local. Do not edit manually; run SUPER+SHIFT+R instead.
FF_KEYS='${HC_PRI[$new_idx]}'
FF_TITLE='${HC_PRI[$new_idx]}'
FF_SEP='${H_DIM[$new_idx]}'
FF_LOGO='${HC_PRI[$new_idx]}'
EOF

notify-send "Theme Changed" "Switched to $NEW_THEME theme" -i preferences-desktop-theme
