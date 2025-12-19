# Advanced Control Panel (v5.2.0) - Universal Roblox Client Script

A universal client-side control panel for Roblox executors. It builds an animated UI with movement tools, ESP, aimbot, utility actions, config import/export, and optional Discord webhook logging.

## Script
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Ninnyyy/myscript.lua/main/Roblox%20script/myscript.lua"))()
```

## Requirements
- Executor with `loadstring` and `HttpGet` enabled.
- For webhook logging, your executor must expose `http_request`.

## Features
- Movement: speed/jump boosts, fly, noclip, presets.
- Visuals: player ESP (names, distance, arrows, healthbar), FOV slider, blur toggle.
- Combat: aimbot (hold RMB), FOV/smooth sliders, triggerbot.
- Utility: teleports, rejoin, auto-clicker, auto-interact, server hop.
- Config: import/export, theme selector, keybinds, presets.
- Status: FPS/Ping overlay.
- Logging: optional Discord webhook.

## Keys
- Toggle UI: L
- Panic: RightControl (removes UI, resets walk/jump).

## Notes
- Client-side only; does not modify server data.
- Some features rely on game objects and may not work in every experience.
- If `config.disableInVIP` is true, the script auto-disables in VIP/private servers.

## Troubleshooting
- `attempt to call a nil value` at line 1: `loadstring` returned nil; confirm your executor supports `loadstring` and `HttpGet`.
- `loadstring: nil: <line> ...`: syntax error in the remote file or the URL returned HTML. Pull latest script and check the URL in a browser.
- UI not showing: check the menu key, ensure panic is not active, and check the executor console for errors.
- Webhook not firing: set `config.webhookUrl` and verify `http_request` works in your executor.
