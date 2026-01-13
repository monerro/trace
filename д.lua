-- TR4CE loader

local BASE_URL = "https://raw.githubusercontent.com/monerro/trace/main/"

local function Load(path)
    return loadstring(game:HttpGet(BASE_URL .. path))()
end

-- load core
local Services = Load("services.lua")
local Settings = Load("settings.lua")
local IsHostileTeam = Load("teams.lua")

-- load ui
local UI = Load("ui.lua")

-- load features
Load("aimbot.lua")
Load("esp.lua")
Load("damage.lua")
Load("misc.lua")
Load("position_hider.lua")

UI:Notify("Loaded", 5)
