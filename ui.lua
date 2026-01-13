--// UI CREATION
local Players = _G.Players
local LocalPlayer = _G.LocalPlayer
local Settings = _G.Settings
local Library = _G.Library
local ThemeManager = _G.ThemeManager
local SaveManager = _G.SaveManager

-- Create Window
local Window = Library:CreateWindow({
    Title = 'TR4CE SCP Roleplay Framework',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

-- UI styling
Library.AccentColor = Color3.fromRGB(255, 80, 10)
Library.AccentColorDark = Color3.fromRGB(200, 60, 5)
Library.MainColor = Color3.fromRGB(25, 25, 30)
Library.BackgroundColor = Color3.fromRGB(20, 20, 25)
Library.OutlineColor = Color3.fromRGB(45, 45, 55)
Library.FontColor = Color3.fromRGB(255, 255, 255)

Library:SetWatermarkVisibility(true)
Library:SetWatermark('TR4CE SCP | ' .. LocalPlayer.Name)

-- Create tabs
local Tabs = {
    Aimbot = Window:AddTab('Aimbot'),
    Visuals = Window:AddTab('Visuals'),
    Misc = Window:AddTab('Misc'),
    Config = Window:AddTab('Config'),
    ['UI Settings'] = Window:AddTab('UI Settings')
}

-- ========== AIMBOT TAB ==========
local AimbotBox = Tabs.Aimbot:AddLeftGroupbox('Aimbot Settings')

AimbotBox:AddToggle('AimbotEnabled', {
    Text = 'Enable Aimbot',
    Default = false,
    Callback = function(val) Settings.Aim.Enabled = val end
})

AimbotBox:AddToggle('TeamCheck', {
    Text = 'Team Check',
    Default = true,
    Callback = function(val) Settings.Aim.TeamCheck = val end
})

AimbotBox:AddToggle('WallCheck', {
    Text = 'Wall Check',
    Default = false,
    Callback = function(val) Settings.Aim.WallCheck = val end
})

AimbotBox:AddToggle('HoldMode', {
    Text = 'Hold Mode (vs Toggle)',
    Default = true,
    Callback = function(val)
        Settings.Aim.HoldMode = val
        _G.aimbotToggled = false
    end
})

AimbotBox:AddToggle('ADSOnly', {
    Text = 'Aim Only When ADSing',
    Default = true,
    Callback = function(val) Settings.Aim.ADSOnly = val end
})

-- Custom Team Targeting
AimbotBox:AddToggle('CustomTeams', {
    Text = 'Custom Team Targeting',
    Default = false,
    Callback = function(val) 
        Settings.Aim.CustomTeams = val 
    end
})

AimbotBox:AddSlider('Smoothness', {
    Text = 'Smoothness',
    Default = 15,
    Min = 1,
    Max = 100,
    Rounding = 0,
    Suffix = '%',
    Callback = function(val) Settings.Aim.Smoothness = val / 100 end
})

AimbotBox:AddDropdown('TargetPart', {
    Values = {'Head', 'UpperTorso', 'HumanoidRootPart'},
    Default = 1,
    Multi = false,
    Text = 'Target Part',
    Callback = function(val) Settings.Aim.BodyPart = val end
})

-- Team Selection (only shown when CustomTeams is enabled)
local teamOptions = {'Class-D', 'Chaos Insurgency', 'Security Department', 
                     'Scientific Department', 'Medical Department', 
                     'Rapid Response', 'Mobile Task Force', 'Internal Security'}

local teamSelector = AimbotBox:AddDropdown('TargetTeams', {
    Values = teamOptions,
    Default = 1,
    Multi = true,
    Text = 'Select Target Teams',
    Callback = function(selected)
        -- Reset all
        for teamName, _ in pairs(Settings.Aim.TargetTeams) do
            Settings.Aim.TargetTeams[teamName] = false
        end
        
        -- Set selected
        for _, team in ipairs(selected) do
            local teamLower = team:lower()
            Settings.Aim.TargetTeams[teamLower] = true
        end
    end
})

-- Set initial selection
local initialTeams = {}
for teamName, isTarget in pairs(Settings.Aim.TargetTeams) do
    if isTarget then
        -- Format for display
        local displayName = teamName:gsub("^%l", string.upper)
        if displayName == "Class-d" then displayName = "Class-D" end
        table.insert(initialTeams, displayName)
    end
end
teamSelector:SetValues(initialTeams)

-- FOV Settings
local FOVBox = Tabs.Aimbot:AddRightGroupbox('FOV Settings')

FOVBox:AddToggle('FOVCircle', {
    Text = 'Show FOV Circle',
    Default = true,
    Callback = function(val) Settings.FOV.DrawCircle = val end
})

FOVBox:AddSlider('FOVRadius', {
    Text = 'FOV Radius',
    Default = 150,
    Min = 50,
    Max = 500,
    Rounding = 0,
    Suffix = 'px',
    Callback = function(val) Settings.FOV.Radius = val end
})

-- ========== VISUALS TAB ==========
local ESPBox = Tabs.Visuals:AddLeftGroupbox('ESP Settings')

ESPBox:AddToggle('ESPEnabled', {
    Text = 'Enable ESP',
    Default = false,
    Callback = function(val) Settings.ESP.Enabled = val end
})

ESPBox:AddToggle('TeamCheck', {
    Text = 'Team Check',
    Default = true,
    Callback = function(val) Settings.ESP.TeamCheck = val end
})

ESPBox:AddToggle('ShowBoxes', {
    Text = 'Show Boxes',
    Default = true,
    Callback = function(val) Settings.ESP.ShowBoxes = val end
})

ESPBox:AddToggle('ShowNames', {
    Text = 'Show Names',
    Default = true,
    Callback = function(val) Settings.ESP.ShowNames = val end
})

ESPBox:AddToggle('ShowHealth', {
    Text = 'Show Health',
    Default = true,
    Callback = function(val) Settings.ESP.ShowHealth = val end
})

-- ESP Customization
local ESPCustomBox = Tabs.Visuals:AddRightGroupbox('ESP Colors')

ESPCustomBox:AddLabel('Class-D Color:'):AddColorPicker('ClassDColor', {
    Default = Settings.ESP.ClassDColor,
    Callback = function(val) Settings.ESP.ClassDColor = val end
})

ESPCustomBox:AddLabel('Security Color:'):AddColorPicker('SecurityColor', {
    Default = Settings.ESP.SecurityColor,
    Callback = function(val) Settings.ESP.SecurityColor = val end
})

-- ========== MISC TAB ==========
local MiscBox = Tabs.Misc:AddLeftGroupbox('Player Features')

MiscBox:AddToggle('HideCharacter', {
    Text = 'Hide Character',
    Default = false,
    Callback = function(val)
        Settings.Misc.HideCharacter = val
        if LocalPlayer.Character then
            if val then 
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.LocalTransparencyModifier = 1
                    end
                end
            else
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.LocalTransparencyModifier = 0
                    end
                end
            end
        end
    end
})

MiscBox:AddToggle('Noclip', {
    Text = 'Noclip (Press N)',
    Default = false,
    Callback = function(val)
        Settings.Misc.Noclip = val
        if val then 
            _G.enableNoclip()
        else 
            _G.disableNoclip() 
        end
    end
})

MiscBox:AddToggle('InfiniteJump', {
    Text = 'Infinite Jump',
    Default = false,
    Callback = function(val) Settings.Misc.InfiniteJump = val end
})

-- Position Hider
MiscBox:AddDivider()
MiscBox:AddLabel("Position Hider")

MiscBox:AddToggle('PositionHiderEnabled', {
    Text = 'Enable Position Hider',
    Default = false,
    Callback = function(val) Settings.PositionHider.Enabled = val end
})

MiscBox:AddButton('Hide at Position', function()
    if Settings.PositionHider.Enabled then
        _G.simpleHideAtPosition()
    else
        Library:Notify("Enable Position Hider first!", 2)
    end
end)

-- Visual Features
local MiscBox2 = Tabs.Misc:AddRightGroupbox('Visual Features')

MiscBox2:AddToggle('Fullbright', {
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

-- Damage Indicator
local DamageBox = Tabs.Misc:AddRightGroupbox('Damage Indicator')

DamageBox:AddToggle('DamageEnabled', {
    Text = 'Enable Damage Indicator',
    Default = false,
    Callback = function(val)
        Settings.Damage.Enabled = val
        if val then 
            _G.enableDamageIndicator() 
        else 
            _G.disableDamageIndicator() 
        end
    end
})

DamageBox:AddToggle('HitSound', {
    Text = 'Hit Sound',
    Default = false,
    Callback = function(val) Settings.Damage.HitSound = val end
})

-- ========== CONFIG TAB ==========
local ConfigBox = Tabs.Config:AddLeftGroupbox('Framework Info')

ConfigBox:AddLabel('TR4CE SCP Roleplay')
ConfigBox:AddLabel('Version: 2.0 (Modular)')
ConfigBox:AddDivider()
ConfigBox:AddLabel('Features:')
ConfigBox:AddLabel('• Team-Based Aimbot')
ConfigBox:AddLabel('• Custom ESP Colors')
ConfigBox:AddLabel('• Position Hider')
ConfigBox:AddLabel('• Damage Indicator')

-- ========== UI SETTINGS TAB ==========
local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')

MenuGroup:AddButton('Unload Script', function() 
    Library:Unload() 
end)

MenuGroup:AddLabel('Menu Keybind'):AddKeyPicker('MenuKeybind', {
    Default = 'End',
    NoUI = true,
    Text = 'Menu toggle key',
})

-- Theme Manager
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder('TR4CE_SCP')
ThemeManager:ApplyToTab(Tabs['UI Settings'])

-- Save Manager
SaveManager:SetLibrary(Library)
SaveManager:SetFolder('TR4CE_SCP/configs')
SaveManager:BuildConfigSection(Tabs['UI Settings'])

print("[TR4CE] UI loaded successfully")
