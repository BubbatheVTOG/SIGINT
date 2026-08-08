-- Hyprland Lua Configuration - Host: matt (desktop)
-- Sources the shared base, then adds desktop-specific config.

dofile(os.getenv("HOME") .. "/.config/hypr/hyprland.base.lua")

------------------
---- MONITORS ----
------------------

-- TODO: run `hyprctl monitors` on matt and confirm output names + refresh rates.
-- Placeholder layout: DP-1 = 2560x1440 (center), DP-2 = 1920x1080 (left), HDMI-A-1 = 1920x1080 (right)

hl.monitor({
    output   = "DP-1",
    mode     = "2560x1440@144",
    position = "1920x0",
    scale    = 1.0,
})

hl.monitor({
    output   = "DP-2",
    mode     = "1920x1080@60",
    position = "0x0",
    scale    = 1.0,
})

hl.monitor({
    output   = "HDMI-A-1",
    mode     = "1920x1080@60",
    position = "4480x0",
    scale    = 1.0,
})
