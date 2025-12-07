local FrameworkName = nil
local ESX, QBCore = nil, nil
local OxInventoryReady = false

local function DetectFramework()
    local esxSuccess = pcall(function()
        if GetResourceState('es_extended') == 'started' then
            ESX = exports['es_extended']:getSharedObject()
            return true
        end
        return false
    end)

    local qbSuccess = pcall(function()
        if GetResourceState('qb-core') == 'started' then
            QBCore = exports['qb-core']:GetCoreObject()
            return true
        end
        return false
    end)

    local oxSuccess = pcall(function()
        if GetResourceState('ox_inventory') == 'started' then
            return exports.ox_inventory ~= nil
        end
        return false
    end)

    if esxSuccess and ESX then
        FrameworkName = 'ESX'
        return true
    elseif qbSuccess and QBCore then
        FrameworkName = 'QBCore'
        return true
    elseif oxSuccess then
        FrameworkName = 'ox_inventory'
        OxInventoryReady = true
        return true
    end

    return false
end

if Config.Framework == 'auto' then
    if DetectFramework() then
        print('[NKHD Cartridges] Framework: ' .. FrameworkName)
    else
        print('[NKHD Cartridges] No Framework was Found!')
    end
elseif Config.Framework == 'ESX' then
    ESX = exports['es_extended']:getSharedObject()
    FrameworkName = 'ESX'
elseif Config.Framework == 'QBCore' then
    QBCore = exports['qb-core']:GetCoreObject()
    FrameworkName = 'QBCore'
elseif Config.Framework == 'ox_inventory' then
    if GetResourceState('ox_inventory') == 'started' then
        FrameworkName = 'ox_inventory'
        OxInventoryReady = true
    else
        print('[NKHD Cartridges] ox_inventory was requested but is not started!')
    end
else
    print('[NKHD Cartridges] No Framework was Found!')
end

local function getAvailableCartridges(src)
    if FrameworkName == 'ESX' then
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer then
            local cartridgeItem = xPlayer.getInventoryItem(Config.ESXItemName)
            if cartridgeItem then
                return cartridgeItem.count
            end
        end
    elseif FrameworkName == 'QBCore' then
        local qbPlayer = QBCore.Functions.GetPlayer(src)
        if qbPlayer then
            local cartridgeItem = qbPlayer.Functions.GetItemByName(Config.QBCoreItemName)
            if cartridgeItem then
                return cartridgeItem.amount
            end
        end
    elseif FrameworkName == 'ox_inventory' and OxInventoryReady then
        local count = exports.ox_inventory:Search(src, 'count', Config.OxInventoryItemName)
        if count then
            return count
        end
    end

    return 0
end

local function consumeCartridge(src)
    if FrameworkName == 'ESX' then
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer then
            local cartridgeItem = xPlayer.getInventoryItem(Config.ESXItemName)
            if cartridgeItem and cartridgeItem.count > 0 then
                xPlayer.removeInventoryItem(Config.ESXItemName, 1)
                return true
            end
        end
    elseif FrameworkName == 'QBCore' then
        local qbPlayer = QBCore.Functions.GetPlayer(src)
        if qbPlayer then
            local cartridgeItem = qbPlayer.Functions.GetItemByName(Config.QBCoreItemName)
            if cartridgeItem and cartridgeItem.amount > 0 then
                qbPlayer.Functions.RemoveItem(Config.QBCoreItemName, 1)
                return true
            end
        end
    elseif FrameworkName == 'ox_inventory' and OxInventoryReady then
        local removed = exports.ox_inventory:RemoveItem(src, Config.OxInventoryItemName, 1)
        if removed then
            return true
        end
    end

    return false
end

RegisterServerEvent('checkTaserCartridgesCount')
AddEventHandler('checkTaserCartridgesCount', function()
    local src = source

    if not FrameworkName then
        TriggerClientEvent('updateTaserCartridgesCount', src, 0)
        return
    end

    local availableCartridges = getAvailableCartridges(src)
    TriggerClientEvent('updateTaserCartridgesCount', src, availableCartridges)
end)

RegisterServerEvent('checkTaserCartridges')
AddEventHandler('checkTaserCartridges', function()
    local src = source

    if not FrameworkName then
        print('[NKHD Cartridges] No Framework was Found!')
        TriggerClientEvent('reloadTaser', src, false)
        return
    end

    local hasCartridge = consumeCartridge(src)
    local availableCartridges = getAvailableCartridges(src)

    TriggerClientEvent('reloadTaser', src, hasCartridge, availableCartridges)
end)
