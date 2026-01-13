--// TR4CE | SCP ROLEPLAY Framework
--// MAIN LOADER - FIXED VERSION

local repo = "https://raw.githubusercontent.com/monerro/trace/main/"

print("[TR4CE] ===========================================")
print("[TR4CE] Starting TR4CE SCP Framework")
print("[TRACE] Loading modules...")

-- SETUP SERVICES FIRST
_G.Players = game:GetService("Players")
_G.RunService = game:GetService("RunService")
_G.UserInputService = game:GetService("UserInputService")
_G.TweenService = game:GetService("TweenService")
_G.Camera = workspace.CurrentCamera
_G.HttpService = game:GetService("HttpService")
_G.Lighting = game:GetService("Lighting")
_G.LocalPlayer = _G.Players.LocalPlayer
_G.Mouse = _G.LocalPlayer:GetMouse()

print("[TR4CE] Services initialized")

-- LOAD DEPENDENCIES
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/SaveManager.lua"))()

_G.Library = Library
_G.ThemeManager = ThemeManager
_G.SaveManager = SaveManager

print("[TR4CE] Dependencies loaded")

-- LOAD MODULES IN ORDER
local modules = {
    "config",
    "utils", 
    "whitelist",
    "aimbot",
    "esp",
    "damage",
    "misc",
    "ui"
}

for i, module in ipairs(modules) do
    print("[TR4CE] [" .. i .. "/" .. #modules .. "] Loading " .. module)
    
    local success, err = pcall(function()
        local content = game:HttpGet(repo .. module .. ".lua")
        loadstring(content)()
    end)
    
    if success then
        print("[TR4CE] ✓ " .. module .. " loaded")
    else
        print("[TR4CE] ✗ " .. module .. " failed: " .. tostring(err))
    end
end

print("[TR4CE] ===========================================")
print("[TR4CE] ALL MODULES LOADED SUCCESSFULLY!")
print("[TR4CE] User: " .. _G.LocalPlayer.Name)
print("[TR4CE] ===========================================")

-- Show notification
Library:SetWatermarkVisibility(true)
Library:SetWatermark('TR4CE SCP | ' .. _G.LocalPlayer.Name)

if Library.Notify then
    Library:Notify('TR4CE SCP Roleplay loaded! Press END to toggle menu', 5)
end
