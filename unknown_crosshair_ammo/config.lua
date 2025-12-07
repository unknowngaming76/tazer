-- unknown_crosshair_ammo / config.lua
config = {}

-- Crosshair settings
config.crosshair = {
    dotSize = 0.0009,            -- size of the dot (screen units)
    alpha = 255,                 -- 0-255 alpha for dot

    enabled = true,                -- master toggle
    showWhenAimingOnly = false,    -- false = show whenever a firearm is out (your ask); true = only while aiming
    hideDefaultReticle = true,     -- hide GTA's default reticle while ours is visible
    size = 0.001,                  -- length of each crosshair arm
    thickness = 0.0015,            -- line thickness
    gap = 0.004,                   -- gap between center and each arm
    alpha = 220,                   -- 0-255 transparency
}

-- Ammo text settings
config.ammo = {
    enabled = true,
    showWeaponName = false,        -- include weapon label (hash) before the ammo
    x = 0.985,                     -- top-right
    y = 0.02,
    scale = 0.5,                   -- text scale
    padRight = true,               -- right-justify against x
}

-- Performance
config.tickWhenHidden = 0       -- ms wait when no crosshair/ammo is needed
