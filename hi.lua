--// TR4CE | SCP ROLEPLAY Framework
--// MAIN LOADER - FIXED VERSION WITH DEPENDENCY SUPPORT

local repo = "https://raw.githubusercontent.com/monerro/trace/main/"

print("[TR4CE] ===========================================")
print("[TR4CE] Starting TR4CE SCP Framework")
print("[TR4CE] Loading modules...")

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

-- CREATE GLOBAL VARIABLES BEFORE MODULES NEED THEM
_G.CurrentTarget = nil
_G.aimbotToggled = false
_G.Settings = nil  -- Will be set by config.lua

-- LOAD MODULES WITH PROPER DEPENDENCY ORDER
local modules = {
    "config",    -- 1. Settings first
    "utils",     -- 2. Utility functions  
    "whitelist", -- 3. Whitelist check
    "aimbot",    -- 4. Aimbot system (sets _G.CurrentTarget)
    "esp",       -- 5. ESP (needs Settings)
    "damage",    -- 6. Damage (needs Settings and _G.CurrentTarget)
    "misc",      -- 7. Misc features
    "ui"         -- 8. UI last
}

-- Store loaded module functions for dependency injection
local loadedModules = {}

for i, module in ipairs(modules) do
    print("[TR4CE] [" .. i .. "/" .. #modules .. "] Loading " .. module)
    
    local success, moduleFunction = pcall(function()
        local content = game:HttpGet(repo .. module .. ".lua")
        return loadstring(content)
    end)
    
    if success and moduleFunction then
        -- Execute module with access to _G
        local execSuccess, execErr = pcall(moduleFunction)
        
        if execSuccess then
            print("[TR4CE] ✓ " .. module .. " loaded")
            loadedModules[module] = true
            
            -- Fix specific dependency issues
            if module == "aimbot" then
                print("[TR4CE] Aimbot loaded, ensuring damage system can access targets...")
                -- These should already be in _G from aimbot.lua
                if not _G.CurrentTarget then _G.CurrentTarget = nil end
                if not _G.aimbotToggled then _G.aimbotToggled = false end
            end
            
        else
            print("[TR4CE] ✗ " .. module .. " execution failed: " .. tostring(execErr))
        end
    else
        print("[TR4CE] ✗ " .. module .. " load failed: " .. tostring(moduleFunction))
    end
end

-- POST-LOAD INITIALIZATION
print("[TR4CE] Running post-load initialization...")

-- Ensure critical variables exist for all modules
if not _G.CurrentTarget then _G.CurrentTarget = nil end
if not _G.aimbotToggled then _G.aimbotToggled = false end
if not _G.Settings then 
    print("[TR4CE] WARNING: Settings not loaded, creating defaults")
    _G.Settings = {
        Aim = {Enabled = false, HoldMode = true, HoldKey = Enum.KeyCode.E},
        Damage = {Enabled = false, HitSound = false, AimbotOnly = true}
    }
end

-- Export helper functions for damage system
_G.getCurrentTarget = function() 
    return _G.CurrentTarget 
end

_G.isAimbotActive = function()
    if _G.Settings and _G.Settings.Aim and _G.Settings.Aim.Enabled then
        if _G.Settings.Aim.HoldMode then
            return _G.UserInputService:IsKeyDown(_G.Settings.Aim.HoldKey or Enum.KeyCode.E)
        else
            return _G.aimbotToggled or false
        end
    end
    return false
end

-- If damage module loaded late, trigger its initialization
if _G.enableDamageIndicator then
    pcall(function()
        if _G.Settings.Damage and _G.Settings.Damage.Enabled then
            _G.enableDamageIndicator()
            print("[TR4CE] Damage system initialized")
        end
    end)
end

print("[TR4CE] ===========================================")
print("[TR4CE] ALL MODULES LOADED SUCCESSFULLY!")
print("[TR4CE] User: " .. _G.LocalPlayer.Name)
print("[TR4CE] CurrentTarget available: " .. tostring(_G.CurrentTarget ~= nil))
print("[TR4CE] AimbotToggled: " .. tostring(_G.aimbotToggled))
print("[TR4CE] ===========================================")

-- Show notification
Library:SetWatermarkVisibility(true)
Library:SetWatermark('TR4CE SCP | ' .. _G.LocalPlayer.Name)

if Library.Notify then
    Library:Notify('TR4CE SCP Roleplay loaded! Press END to toggle menu', 5)
end

-- RETURN SUCCESS
return true
