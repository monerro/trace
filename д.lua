-- hi :)

local repo = "https://raw.githubusercontent.com/monerro/trace/main/"

-- Load dependencies first
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/SaveManager.lua"))()

print("[TR4CE] Loading modules...")

-- Load modules in order
local whitelist = loadstring(game:HttpGet(repo .. "whitelist.lua"))()
local config = loadstring(game:HttpGet(repo .. "config.lua"))()
local utils = loadstring(game:HttpGet(repo .. "utils.lua"))()
local aimbot = loadstring(game:HttpGet(repo .. "aimbot.lua"))()
local esp = loadstring(game:HttpGet(repo .. "esp.lua"))()
local damage = loadstring(game:HttpGet(repo .. "damage.lua"))()
local misc = loadstring(game:HttpGet(repo .. "misc.lua"))()
local ui = loadstring(game:HttpGet(repo .. "ui.lua"))()

print("[TR4CE] All modules loaded successfully!")
print("[TR4CE] Framework initialized for " .. game.Players.LocalPlayer.Name)

Library:Notify('TR4CE SCP Roleplay loaded! Press END to toggle menu', 5)
