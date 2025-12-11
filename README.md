# Advanced Control Panel (v4.2) — Universal Roblox Client Script

A universal client-side control panel for Roblox executors. It builds an animated dark UI with movement tools, ESP, aimbot, utility actions, config import/export, and optional Discord webhook logging.

## Quick Start
1) Put `myscript.lua` in your repo and copy its raw URL (e.g. `https://raw.githubusercontent.com/<user>/<repo>/main/myscript.lua`).
2) In your executor (should work for all roblox executors) then load:
   ```lua
   loadstring(game:HttpGet("https://raw.githubusercontent.com/<user>/<repo>/main/myscript.lua"))()


## Features
## Movement: Speed boost (WalkSpeed slider), High Jump (JumpPower slider), Fly (toggle + speed slider), Noclip, presets (Parkour/Combat).


## Visuals: Player ESP (names, distance, arrows, healthbar), camera FOV slider, background blur toggle.


## Combat: Aimbot (hold RMB) with FOV/smooth sliders, Triggerbot toggle, Reset FOV.


## Utility: Safe-spot teleport, Rejoin, Auto-clicker, Auto-interact (ProximityPrompts), Save current position to teleports, Server hop (lowest ping).


## Config: Copy config to clipboard, Import via modal, Theme selector (Blue/NeoGreen/Amber/Purple), Webhook test, Update check, change Menu/Panic keys.


## Status: FPS/Ping/Player count overlay. Optional blur.


## Logging: If config.webhookUrl is set, key actions (toggles, teleports, server hop) POST to your Discord webhook.


## Keys & UI
Toggle UI: L
Panic: RightControl (removes UI, resets walk/jump)
Drag the UI by the title bar (not sliders/buttons).


## Notes
Runs as a LocalScript; no place-id restriction (universal).
Fly uses BodyVelocity and respects the Fly Speed slider.
ESP/aimbot are client-side visual/aim assists; they don’t modify server data.
If your executor doesn’t support http_request, webhook logging will be skipped silently.


## Troubleshooting
Menu not opening: ensure config.menuKey isn’t bound elsewhere; reload script.
Sliders moving the window: drag only via the title bar.
Fly not moving: ensure Fly toggle is ON and Fly Speed > 0; confirm your executor supports BodyVelocity edits.
Webhook not firing: confirm config.webhookUrl is set and executor permits HTTP requests.
