--// UI CREATION - SIMPLE WORKING VERSION
print("[TR4CE] Loading UI...")

local Library = _G.Library
local ThemeManager = _G.ThemeManager
local SaveManager = _G.SaveManager
local Settings = _G.Settings
local LocalPlayer = _G.LocalPlayer

-- Create window
local Window = Library:CreateWindow({
    Title = 'TR4CE SCP Roleplay',
    Center = true,
    AutoShow = true
})

-- Basic styling
Library:SetWatermark('TR4CE | ' .. LocalPlayer.Name)

-- Create tabs
local AimTab = Window:AddTab('Aimbot')
local VisualTab = Window:AddTab('Visuals') 
local MiscTab = Window:AddTab('Misc')
local ConfigTab = Window:AddTab('Config')
local UITab = Window:AddTab('UI Settings')

-- ========== AIMBOT TAB ==========
local AimBox = AimTab:AddLeftGroupbox('Aimbot')

AimBox:AddToggle('AimEnable', {
    Text = 'Enable Aimbot',
    Default = false,
    Callback = function(val) Settings.Aim.Enabled = val end
})

AimBox:AddToggle('AimWallCheck', {
    Text = 'Wall Check',
    Default = false,
    Callback = function(val) Settings.Aim.WallCheck = val end
})

AimBox:AddToggle('AimTeamCheck', {
    Text = 'Team Check',
    Default = true,
    Callback = function(val) Settings.Aim.TeamCheck = val end
})

AimBox:AddSlider('AimSmooth', {
    Text = 'Smoothness',
    Default = 15,
    Min = 1,
    Max = 100,
    Rounding = 0,
    Suffix = '%',
    Callback = function(val) Settings.Aim.Smoothness = val / 100 end
})

-- FOV Settings
local FOVBox = AimTab:AddRightGroupbox('FOV')

FOVBox:AddToggle('FOVShow', {
    Text = 'Show FOV Circle',
    Default = true,
    Callback = function(val) Settings.FOV.DrawCircle = val end
})

FOVBox:AddSlider('FOVSize', {
    Text = 'FOV Radius',
    Default = 150,
    Min = 50,
    Max = 500,
    Rounding = 0,
    Callback = function(val) Settings.FOV.Radius = val end
})

-- ========== VISUALS TAB ==========
local ESPBox = VisualTab:AddLeftGroupbox('ESP')

ESPBox:AddToggle('ESPEnable', {
    Text = 'Enable ESP',
    Default = false,
    Callback = function(val) Settings.ESP.Enabled = val end
})

ESPBox:AddToggle('ESPBoxes', {
    Text = 'Show Boxes',
    Default = true,
    Callback = function(val) Settings.ESP.ShowBoxes = val end
})

ESPBox:AddToggle('ESPNames', {
    Text = 'Show Names',
    Default = true,
    Callback = function(val) Settings.ESP.ShowNames = val end
})

-- ========== MISC TAB ==========
local MiscBox = MiscTab:AddLeftGroupbox('Features')

MiscBox:AddToggle('MiscFullbright', {
    Text = 'Fullbright',
    Default = false,
    Callback = function(val)
        if val then
            _G.EnableFullbright()
        else
            _G.DisableFullbright()
        end
    end
})

MiscBox:AddToggle('MiscNoclip', {
    Text = 'Noclip (Press N)',
    Default = false,
    Callback = function(val)
        Settings.Misc.Noclip = val
        if val then _G.enableNoclip() else _G.disableNoclip() end
    end
})

MiscBox:AddToggle('MiscHideChar', {
    Text = 'Hide Character',
    Default = false,
    Callback = function(val) Settings.Misc.HideCharacter = val end
})

-- Damage Indicator
local DamageBox = MiscTab:AddRightGroupbox('Damage')

DamageBox:AddToggle('DamageEnable', {
    Text = 'Damage Indicator',
    Default = false,
    Callback = function(val)
        Settings.Damage.Enabled = val
        if val then _G.enableDamageIndicator() else _G.disableDamageIndicator() end
    end
})

-- ========== CONFIG TAB ==========
local InfoBox = ConfigTab:AddLeftGroupbox('Info')

InfoBox:AddLabel('TR4CE SCP Framework')
InfoBox:AddLabel('Version: 2.0')
InfoBox:AddDivider()
InfoBox:AddLabel('Modules Loaded:')
InfoBox:AddLabel('• Aimbot with Team Check')
InfoBox:AddLabel('• ESP System')
InfoBox:AddLabel('• Damage Indicator')
InfoBox:AddLabel('• Position Hider')

-- ========== UI SETTINGS TAB ==========
local UIMenu = UITab:AddLeftGroupbox('Menu')

UIMenu:AddButton('Unload', function() Library:Unload() end)

UIMenu:AddLabel('Menu Key'):AddKeyPicker('UIKeybind', {
    Default = 'End',
    NoUI = true,
    Text = 'Menu toggle'
})

-- Setup theme/save managers
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder('TR4CE_SCP')

SaveManager:SetLibrary(Library)  
SaveManager:SetFolder('TR4CE_SCP/configs')

SaveManager:BuildConfigSection(UITab)
ThemeManager:ApplyToTab(UITab)

print("[TR4CE] UI loaded successfully!")
