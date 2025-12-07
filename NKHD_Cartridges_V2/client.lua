local cartridges = Config.MaxCartridges
local cartridgesin = true
local NoCartgridgesMessage = false
local SpamCooldownPressed = false
local isTaserEquipped = false
local playerPed = nil
local availableCartridges = 0

local TASER_HASH = GetHashKey('WEAPON_STUNGUN')

local function ShowNotification(text)
    if Config.EnableUI == false then
        SetNotificationTextEntry("STRING")
        AddTextComponentString(text)
        DrawNotification(false, false)
    end
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
    else
        ShowNotification('~r~There are no Cartridges left.')
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

            if not cartridgesin and IsControlJustReleased(0, Config.ReloadKey) and not SpamCooldownPressed then
                SpamCooldownPressed = true
                if Config.Debug then
                    print('Debug Pressed R')
                end
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
            end
            
            Citizen.Wait(500) 
        end
    end
end)