Config = {}

Config.Framework = 'auto' -- 'auto', 'ESX' or 'QBCore'
Config.Debug = false
Config.SpamCooldown = 2000 -- 2000 = 2 Sekunden

Config.MaxCartridges = 3  -- How many shots per Cartridge
Config.ReloadKey = 45  -- R (https://docs.fivem.net/docs/game-references/controls/)

-- ESX
Config.ESXItemName = 'taser_cartridge'

-- QBCore
Config.QBCoreItemName = 'taser_ammo'

-- Performance
Config.NonTaserTickRate = 250 -- ms (poll faster when taser isn't equipped)

-- UI (disabled; ammo is shown via unknown_crosshair_ammo instead)
Config.EnableUI = false