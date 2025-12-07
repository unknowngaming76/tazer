-- unknown_crosshair_ammo / client.lua
---@diagnostic disable: undefined-global
local function DrawRectCenter(x, y, w, h, a)
    DrawRect(x, y, w, h, 255, 255, 255, a or 200)
end

-- Crosshair visibility state
local crosshairEnabled = true

-- Optional override for taser cartridges provided by NKHD_Cartridges_V2
local taserAmmoOverride = {
    active = false,
    clip = 0,
    reserve = 0
}

RegisterNetEvent('unknown_crosshair_ammo:setTaserAmmo', function(clip, reserve)
    if clip == nil or reserve == nil then
        taserAmmoOverride.active = false
        taserAmmoOverride.clip = 0
        taserAmmoOverride.reserve = 0
        return
    end

    taserAmmoOverride.active = true
    taserAmmoOverride.clip = clip
    taserAmmoOverride.reserve = reserve
end)

-- Command to toggle it on/off
RegisterCommand('togglecrosshair', function()
    crosshairEnabled = not crosshairEnabled
    local msg = crosshairEnabled and '^2Crosshair enabled' or '^1Crosshair disabled'
    print(msg)
end, false)

-- Function to draw a filled circular crosshair
local function DrawCrosshair()
    if not crosshairEnabled then return end

    local radius = config.crosshair.dotSize or 0.0015  -- smaller size
    local alpha  = config.crosshair.alpha or 220
    local steps  = 40
    local layers = 6
    local stepSize = radius / layers

    -- Get current screen resolution to correct aspect ratio
    local resX, resY = GetActiveScreenResolution()
    local aspectRatio = resX / resY

    for r = 0, radius, stepSize do
        for i = 0, 360, 360 / steps do
            local angle = math.rad(i)
            -- adjust X by aspect ratio so the circle doesn’t stretch
            local x = 0.5 + (math.cos(angle) * r) / aspectRatio
            local y = 0.5 + math.sin(angle) * r
            DrawRect(x, y, 0.0005, 0.0005, 255, 255, 255, alpha)
        end
    end
end



local function DrawTextTopRight(text, x, y, scale, rightJustify)
    SetTextFont(4)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    SetTextColour(255, 255, 255, 220)
    SetTextOutline()
    SetTextDropShadow()
    SetTextEntry("STRING")
    AddTextComponentString(text)

    if rightJustify then
        SetTextRightJustify(true)
        SetTextWrap(0.0, x)
    else
        SetTextCentre(false)
        SetTextWrap(x, 1.0)
    end

    DrawText(x, y)
end

local function GetAmmoNumbers(ped, weaponHash)
    -- total ammo the ped has for the weapon
    local totalAmmo = GetAmmoInPedWeapon(ped, weaponHash) or 0
    -- ammo in the current clip
    local _, clipAmmo = GetAmmoInClip(ped, weaponHash)
    clipAmmo = clipAmmo or 0
    -- reserve is everything not in the clip
    local reserve = math.max(totalAmmo - clipAmmo, 0)
    return clipAmmo, reserve
end

local function IsFirearmEquipped(ped, weaponHash, hasWeapon)
    if not hasWeapon or weaponHash == `WEAPON_UNARMED` then return false end
    -- 4 = firearms (exclude melee)
    if not IsPedArmed(ped, 4) then return false end
    return true
end

local function ShouldShowForCurrentState(ped, weaponHash, hasWeapon)
    if not config or not config.crosshair then return false end
    if not IsFirearmEquipped(ped, weaponHash, hasWeapon) then return false end
    if config.crosshair.showWhenAimingOnly then
        return IsPlayerFreeAiming(PlayerId())
    end
    return true
end

CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local hasWeapon, weaponHash = GetCurrentPedWeapon(ped, true)
        local active = ShouldShowForCurrentState(ped, weaponHash, hasWeapon)

        if active then
            if config.crosshair.enabled then
                if config.crosshair.hideDefaultReticle then
                    HideHudComponentThisFrame(14) -- default reticle
                end
                DrawCrosshair()
            end

            if config.ammo.hideDefault then
                HideHudComponentThisFrame(2)  -- weapon icon & ammo
                HideHudComponentThisFrame(20) -- weapon stats (ammo display)
            end

            if config.ammo.enabled then
                local clip, reserve = GetAmmoNumbers(ped, weaponHash)
                if weaponHash == `WEAPON_STUNGUN` and taserAmmoOverride.active then
                    clip = taserAmmoOverride.clip or 0
                    reserve = taserAmmoOverride.reserve or 0
                end
                local txt = ("%d | %d"):format(clip, reserve)
                if config.ammo.showWeaponName then
                    txt = (tostring(weaponHash) .. "  " .. txt)
                end
                DrawTextTopRight(txt, config.ammo.x or 0.985, config.ammo.y or 0.02, config.ammo.scale or 0.5, config.ammo.padRight ~= false)
            end

            Wait(0) -- draw every frame while active
        else
            Wait(config.tickWhenHidden or 250)
        end
    end
end)

-- Optional commands for quick testing/toggles
RegisterCommand('uc_toggle_crosshair', function()
    config.crosshair.enabled = not config.crosshair.enabled
    local m = config.crosshair.enabled and "^2Crosshair: ON" or "^1Crosshair: OFF"
    print(m)
end, false)

RegisterCommand('uc_toggle_ammo', function()
    config.ammo.enabled = not config.ammo.enabled
    local m = config.ammo.enabled and "^2Ammo: ON" or "^1Ammo: OFF"
    print(m)
end, false)
