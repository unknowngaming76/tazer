local cartridges = Config.MaxCartridges
local cartridgesin = true
local NoCartgridgesMessage = false
local SpamCooldownPressed = false
local isTaserEquipped = false
local playerPed = nil
local availableCartridges = 0
local reloadEmotePlaying = false

local TASER_HASH = GetHashKey('WEAPON_STUNGUN')

local function ShowNotification(text)
    if Config.EnableUI == false then
        SetNotificationTextEntry("STRING")
        AddTextComponentString(text)
        DrawNotification(false, false)
    end
end

local function StopReloadEmote()
    if reloadEmotePlaying then
        playerPed = playerPed or PlayerPedId()
        ClearPedSecondaryTask(playerPed)
        reloadEmotePlaying = false
    end
end

local function PlayReloadEmote()
    if reloadEmotePlaying then return end

    playerPed = playerPed or PlayerPedId()

    local animDict = 'random@arrests'
    local animName = 'generic_radio_chatter'

    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Citizen.Wait(0)
    end

    TaskPlayAnim(playerPed, animDict, animName, 8.0, -8.0, -1, 49, 0, false, false, false)
    reloadEmotePlaying = true
end

local function UpdateCrosshairAmmo()
    TriggerEvent('unknown_crosshair_ammo:setTaserAmmo', cartridges, availableCartridges)
end

RegisterNetEvent('spam')
AddEventHandler('spam', function()
    Citizen.SetTimeout(Config.SpamCooldown, function()
        SpamCooldownPressed = false
        if Config.Debug then
            print('Spam Protection Deactivated')
        end
    end)
end)

RegisterNetEvent('updateTaserCartridgesCount')
AddEventHandler('updateTaserCartridgesCount', function(cartridgesCount)
    availableCartridges = cartridgesCount

    UpdateCrosshairAmmo()
end)

RegisterNetEvent('reloadTaser')
AddEventHandler('reloadTaser', function(hasCartridge, cartridgesAvailable)
    if hasCartridge then
        cartridgesin = true
        cartridges = Config.MaxCartridges
        ShowNotification('~g~Taser Reloaded')
        NoCartgridgesMessage = false
        StopReloadEmote()
    else
        ShowNotification('~r~There are no Cartridges left.')
        StopReloadEmote()
    end

    if cartridgesAvailable ~= nil then
        availableCartridges = cartridgesAvailable
    end

    UpdateCrosshairAmmo()
    
    TriggerEvent('spam')
end)

Citizen.CreateThread(function()
    while true do
        playerPed = PlayerPedId()
        local currentWeapon = GetSelectedPedWeapon(playerPed)
        local wasTaserEquipped = isTaserEquipped

        isTaserEquipped = (currentWeapon == TASER_HASH)

        if isTaserEquipped and not wasTaserEquipped then
            TriggerServerEvent('checkTaserCartridgesCount')
            UpdateCrosshairAmmo()
        end

        if isTaserEquipped then
            HideHudComponentThisFrame(2)
            HideHudComponentThisFrame(20)
            HideHudComponentThisFrame(14)
            HideHudComponentThisFrame(9)

            if cartridges <= 0 then
                DisableControlAction(0, 24, true)
                DisableControlAction(0, 257, true)
                DisableControlAction(0, 142, true)
                SetPedInfiniteAmmo(playerPed, false, TASER_HASH)

                if not NoCartgridgesMessage then
                    cartridgesin = false
                    NoCartgridgesMessage = true
                    ShowNotification('~r~Out of cartridges! Press R to reload.')
                end
            end

            local needsReload = cartridges < Config.MaxCartridges

            if needsReload and IsControlJustReleased(0, Config.ReloadKey) and not SpamCooldownPressed then
                SpamCooldownPressed = true

                if Config.Debug then
                    print('Debug Pressed R (taser reload)')
                end

                PlayReloadEmote()
                TriggerServerEvent('checkTaserCartridges')
            end

            if IsPedShooting(playerPed) and cartridges > 0 then
                cartridges = cartridges - 1

                UpdateCrosshairAmmo()

                if cartridges <= 0 and not NoCartgridgesMessage then
                    cartridgesin = false
                    NoCartgridgesMessage = true
                    ShowNotification('~r~Out of cartridges! Press R to reload.')
                end
            end

            Citizen.Wait(0)
        else

            if wasTaserEquipped then
                StopReloadEmote()
            end

            Citizen.Wait(Config.NonTaserTickRate)
        end
    end
end)