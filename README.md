# myscript.lua

This repository contains an expanded Roblox exploit UI script (`script.lua`) that provides a multi-tab interface, module manager, autosaving configurations, and utilities such as notifications and a built-in watermark/fps counter.

## Features
- Acrylic-style UI with tabs, modules, and multiple control types (toggles, sliders, dropdowns, buttons, color pickers, and more).
- Config system that can save, load, export, and import JSON-based profiles.
- New helpers for managing saved configs directly from other scripts:
  - `CLICK_UI.list_configs()` – returns all saved config names.
  - `CLICK_UI.delete_config(name)` – deletes a specific config file (defaults to `default`).
  - `CLICK_UI.save_config_as(name)` – duplicates the current config under a new name.
  - `CLICK_UI.rename_config(old_name, new_name)` – clones and deletes to rename a stored profile.
  - `CLICK_UI.get_config_metadata(name)` – returns creation/update metadata for a stored profile.
  - `CLICK_UI.reset_default_config()` – rebuilds and saves a fresh default config.
- Config files now include metadata (`name`, `created_at`, `updated_at`) so scripts can show timestamps or labels inside the UI.
- Utility functions for safe HTTP requests, optional blur, autosave, notifications, and a watermark showing the local player's name and FPS.

## Usage
Load `script.lua` inside a Roblox exploit environment that exposes functions such as `cloneref`, `writefile`, `readfile`, `isfolder`, `listfiles`, and `delfile`. The script automatically creates and shows the UI, loads the default config if present, and exposes a `CLICK_UI` global for other scripts to reuse the interface and config helpers.