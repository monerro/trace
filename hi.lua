--// TR4CE | SCP ROLEPLAY Framework
--// Main Loader File - FIXED

print("[TR4CE] Starting loader...")

local repo = "https://raw.githubusercontent.com/monerro/trace/main/"

-- STEP 1: CRITICAL - Set up ALL global services FIRST
print("[TR4CE] Setting up global services...")

_G.Players = game:GetService("Players")
_G.RunService = game:GetService("RunService")
_G.UserInputService = game:GetService("UserInputService")
_G.TweenService = game:GetService("TweenService")
_G.Camera = workspace.CurrentCamera
_G.HttpService = game:GetService("HttpService")
_G.LocalPlayer = _G.Players.LocalPlayer
_G.Mouse = _G.LocalPlayer:GetMouse()

print("[TR4CE] Global services ready")

-- STEP 2: Load dependencies
print("[TR4CE] Loading dependencies...")

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/SaveManager.lua"))()

-- Store libraries in _G too
_G.Library = Library
_G.ThemeManager = ThemeManager
_G.SaveManager = SaveManager

print("[TR4CE] Dependencies loaded")

-- STEP 3: Load modules in CORRECT order
print("[TR4CE] Loading modules...")

local modules = {
    "config",     -- Settings (needs nothing)
    "utils",      -- Utility functions (needs Settings)
    "whitelist",  -- Needs Players, LocalPlayer, HttpService from _G
    "services",   -- Other services setup
    "aimbot",     -- Needs Settings, Utils
    "esp",        -- Needs Settings, Utils
    "damage",     -- Needs Settings, CurrentTarget
    "misc",       -- Needs Settings, Library
    "ui"          -- Needs Settings, Library, everything else
}

for i, module in ipairs(modules) do
    print("[TR4CE] [" .. i .. "/" .. #modules .. "] Loading " .. module)
    
    local url = repo .. module .. ".lua"
    
    -- Try to load the module
    local success, err = pcall(function()
        local content = game:HttpGet(url)
        if not content or content == "" then
            error("Empty or no content from: " .. url)
        end
        loadstring(content)()
    end)
    
    if success then
        print("[TR4CE] ✓ " .. module .. " loaded")
    else
        print("[TR4CE] ✗ FAILED: " .. module .. " - " .. tostring(err))
        -- If whitelist fails, we should stop
        if module == "whitelist" then
            print("[TR4CE] CRITICAL: Whitelist failed. Stopping.")
            return
        end
    end
end

print("[TR4CE] ================================")
print("[TR4CE] All modules loaded successfully!")
print("[TR4CE] User: " .. _G.LocalPlayer.Name)
print("[TR4CE] ================================")

-- Final notification
if _G.Library and _G.Library.Notify then
    _G.Library:Notify('TR4CE SCP Roleplay loaded! Press END for menu', 5)
end
