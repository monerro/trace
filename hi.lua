--// TR4CE | SCP ROLEPLAY Framework
--// Main Loader File
--// https://raw.githubusercontent.com/monerro/trace/main/%D0%B4.lua

local repo = "https://raw.githubusercontent.com/monerro/trace/main/"

-- Load dependencies first
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/SaveManager.lua"))()

-- Store library globally for UI module
_G.Library = Library
_G.ThemeManager = ThemeManager
_G.SaveManager = SaveManager

print("[TR4CE] Loading modules...")

-- Load modules in order
loadstring(game:HttpGet(repo .. "services.lua"))()
loadstring(game:HttpGet(repo .. "whitelist.lua"))()
loadstring(game:HttpGet(repo .. "config.lua"))()
loadstring(game:HttpGet(repo .. "utils.lua"))()
loadstring(game:HttpGet(repo .. "aimbot.lua"))()
loadstring(game:HttpGet(repo .. "esp.lua"))()
loadstring(game:HttpGet(repo .. "damage.lua"))()
loadstring(game:HttpGet(repo .. "misc.lua"))()
loadstring(game:HttpGet(repo .. "ui.lua"))()

print("[TR4CE] All modules loaded successfully!")
print("[TR4CE] Framework initialized for " .. game.Players.LocalPlayer.Name)

Library:Notify('TR4CE SCP Roleplay loaded! Press END to toggle menu', 5)
