# unknown_crosshair_ammo

Standalone FiveM resource that draws a simple crosshair and an ammo counter when a firearm is equipped.

## Features
- Crosshair appears whenever a gun is out (default), or only while aiming (configurable).
- Ammo text shown at the top-right by default: `clip | reserve`.
- Optionally hides GTA’s default reticle and ammo HUD to prevent duplicates.
- No framework dependency (works with Qbox/QBCore/ESX/standalone).
- Lightweight: no NUI, drawn via natives.

## Install
1. Drop the `unknown_crosshair_ammo` folder into your `resources/`.
2. Add `ensure unknown_crosshair_ammo` to your `server.cfg` **after** your core/framework.
3. Restart the server or resource.

## Config
See `config.lua`:
- `crosshair.showWhenAimingOnly = false` (set `true` if you only want it while aiming).
- Tweak `size`, `thickness`, `gap`, `alpha` for the crosshair.
- `ammo.hideDefault = true` to hide GTA's default ammo display while this resource is active.
- Move ammo display by changing `ammo.x`, `ammo.y`, `ammo.scale`.

## Commands
- `/uc_toggle_crosshair` – toggle crosshair on/off.
- `/uc_toggle_ammo` – toggle ammo text on/off.
