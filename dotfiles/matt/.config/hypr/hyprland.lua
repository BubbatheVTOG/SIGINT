-- Hyprland Lua Configuration - Host: matt (desktop)
-- Adapted from sigint's confirmed-working config + Hyprland 0.56 hl.* API docs.
-- Hardware: 3 monitors (DP-4 left/rotated, DP-5 center, DP-6 right/rotated).
-- Differences from sigint: no lid handling, no battery/brightness keys,
-- voxtype for speech-to-text (not nerd-dictation), SUPER+SHIFT+R theme toggle.

------------------
---- MONITORS ----
------------------
-- From `hyprctl monitors` on matt (2026-08-08):
--   DP-4: HP E243m   1920x1080@60  at 0x0     transform 1 (90 deg)
--   DP-5: Acer XB270HU 2560x1440@144 at 1080x0  (main)
--   DP-6: preferred  at 3640x0  transform 3 (270 deg)

hl.monitor({
    output    = "DP-4",
    mode      = "1920x1080@60",
    position  = "0x0",
    scale     = 1.0,
    transform = 1,
})

hl.monitor({
    output   = "DP-5",
    mode     = "2560x1440@144",
    position = "1080x0",
    scale    = 1.0,
})

hl.monitor({
    output    = "DP-6",
    mode      = "preferred",
    position  = "3640x0",
    scale     = 1.0,
    transform = 3,
})

---------------------
---- MY PROGRAMS ----
---------------------

local terminal    = "kitty"
local fileManager = "dolphin"
local menu        = "rofi -show drun"
local browser     = "firefox"

-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function ()
    hl.exec_cmd("nm-applet")
    hl.exec_cmd("waybar")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("dunst")
    hl.exec_cmd("voxtype daemon")
end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
    misc = {
        force_default_wallpaper = -1,
        disable_hyprland_logo   = false,
    },

    general = {
        gaps_in  = 5,
        gaps_out = 10,

        border_size = 2,

        -- NOTE: theme toggle (SUPER+SHIFT+R) sed-replaces 33ccffee <-> ef596fee
        -- and 00ff99ee <-> d8985fee. Keep these exact strings.
        col = {
            active_border   = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
            inactive_border = "rgba(00FFFFEE)",
        },

        resize_on_border = false,
        allow_tearing    = false,
        layout           = "dwindle",
    },

    decoration = {
        rounding       = 0,
        rounding_power = 0,

        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = "rgba(1a1a1aee)",
        },

        blur = {
            enabled           = true,
            size              = 3,
            passes            = 1,
            vibrancy          = 0.1696,
            new_optimizations = true,
        },
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        preserve_split = true,
    },

    master = {
        new_status = "master",
    },

    debug = {
        disable_logs = false,
    },

    input = {
        kb_layout  = "us",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        follow_mouse = 1,
        sensitivity  = 0,

        touchpad = {
            natural_scroll = false,
        },
    },
})

--------------------
---- ANIMATIONS ----
--------------------

hl.curve("easeOutQuint",   { type = "bezier", points = { { 0.23, 1 },    { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear",         { type = "bezier", points = { { 0, 0 },       { 1, 1 } } })
hl.curve("almostLinear",   { type = "bezier", points = { { 0.5, 0.5 },   { 0.75, 1 } } })
hl.curve("quick",          { type = "bezier", points = { { 0.15, 0 },    { 0.1, 1 } } })

hl.animation({ leaf = "global",        enabled = true, speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 4.1,  bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor",    enabled = true, speed = 7,    bezier = "quick" })

------------------
---- GESTURES ----
------------------

hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})

-----------------
---- DEVICES ----
-----------------

hl.device({
    name        = "epic-mouse-v1",
    sensitivity = -0.5,
})

---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER"

hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind("SUPER + SHIFT + Q", hl.dsp.exit())
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + O", hl.dsp.exec_cmd(terminal .. " opencode"))
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("/home/bubba/.local/bin/toggle-theme.sh"))

-- Voxtype speech-to-text: SUPER+M toggles recording
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("voxtype record toggle"))

-- Screenshot keybindings
hl.bind("CTRL + SHIFT + 4", hl.dsp.exec_cmd('grim -g "$(slurp)" - | wl-copy && notify-send "Screenshot copied to clipboard"'))
hl.bind("CTRL + SHIFT + 5", hl.dsp.exec_cmd('grim - | wl-copy && notify-send "Full screenshot copied to clipboard"'))

-- Move focus with mainMod + h/j/k/l
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Navigate workspaces with Z (previous) and X (next)
hl.bind(mainMod .. " + Z", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + X", hl.dsp.focus({ workspace = "e+1" }))

-- Special workspace (scratchpad)
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Volume keys (desktop keyboard; locked + repeating)
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })

-- Media keys
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

----------------------
---- WINDOW RULES ----
----------------------

-- Ignore maximize requests from apps
hl.window_rule({
    name           = "suppress-maximize-events",
    match          = { class = ".*" },
    suppress_event = "maximize",
})

-- Fix some dragging issues with XWayland
hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})
