--// TR4CE | SCP ROLEPLAY Framework
--// Main Loader File - COMPLETE FIX

print("[TR4CE] Starting loader...")

local repo = "https://raw.githubusercontent.com/monerro/trace/main/"

-- STEP 1: Set up ALL global services FIRST
print("[TR4CE] Setting up global services...")

_G.Players = game:GetService("Players")
_G.RunService = game:GetService("RunService")
_G.UserInputService = game:GetService("UserInputService")
_G.TweenService = game:GetService("TweenService")
_G.Camera = workspace.CurrentCamera
_G.HttpService = game:GetService("HttpService")
_G.Lighting = game:GetService("Lighting")
_G.LocalPlayer = _G.Players.LocalPlayer

print("[TR4CE] Global services ready")

-- STEP 2: Load LinoriaLib CORRECTLY
print("[TR4CE] Loading LinoriaLib...")

local Linoria = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/SaveManager.lua"))()

-- Store EVERYTHING in _G
_G.Library = Linoria
_G.ThemeManager = ThemeManager
_G.SaveManager = SaveManager

print("[TR4CE] LinoriaLib loaded")

-- STEP 3: Load modules
print("[TR4CE] Loading modules...")

local modules = {
    "config",     -- Settings
    "utils",      -- Utility functions
    "whitelist",  -- Whitelist check
    "aimbot",     -- Aimbot system
    "esp",        -- ESP system  
    "damage",     -- Damage indicator
    "misc",       -- Misc features
    "ui"          -- UI (needs everything above)
}

for i, module in ipairs(modules) do
    print("[TR4CE] [" .. i .. "/" .. #modules .. "] Loading " .. module)
    
    local url = repo .. module .. ".lua"
    local success, err = pcall(function()
        local content = game:HttpGet(url)
        if not content then error("No content from: " .. url) end
        loadstring(content)()
    end)
    
    if success then
        print("[TR4CE] ✓ " .. module .. " loaded")
    else
        print("[TR4CE] ✗ FAILED: " .. module .. " - " .. tostring(err))
    end
end

print("[TR4CE] ================================")
print("[TR4CE] Loader complete!")
print("[TR4CE] User: " .. _G.LocalPlayer.Name)
print("[TR4CE] ================================")
