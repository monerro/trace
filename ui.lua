--// UI CREATION
local Players = _G.Players
local LocalPlayer = _G.LocalPlayer
local Settings = _G.Settings
local Library = _G.Library
local ThemeManager = _G.ThemeManager
local SaveManager = _G.SaveManager

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

-- Tabs
local Tabs = {
    Aimbot = Window:AddTab('Aimbot'),
    Visuals = Window:AddTab('Visuals'),
    Misc = Window:AddTab('Misc'),
    Config = Window:AddTab('Config'),
    ['UI Settings'] = Window:AddTab('UI Settings')
}

-- Aimbot Tab
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
AimbotBox:AddToggle('WallCheck', {
    Text = 'Wall Check',
    Default = false,
    Tooltip = 'Only aim through walls',
    Callback = function(val) Settings.Aim.WallCheck = val end
})

AimbotBox:AddToggle('CustomTeams', {
    Text = 'Custom Team Targeting',
    Default = false,
    Tooltip = 'Choose which teams to aim at',
    Callback = function(val) 
        Settings.Aim.CustomTeams = val 
    end
})

-- Add team selection (add this after the toggles)
local TeamSelector = AimbotBox:AddDropdown('TeamSelection', {
    Values = {'Class-D', 'Chaos Insurgency', 'Security Department', 'Scientific Department', 
              'Medical Department', 'Rapid Response', 'Mobile Task Force', 'Internal Security'},
    Default = 1,
    Multi = true,
    Text = 'Target Teams',
    Callback = function(selected)
        -- Reset all to false
        for teamName, _ in pairs(Settings.Aim.TargetTeams) do
            Settings.Aim.TargetTeams[teamName] = false
        end
        
        -- Set selected teams to true
        for _, team in ipairs(selected) do
            local teamLower = team:lower()
            Settings.Aim.TargetTeams[teamLower] = true
        end
    end
})

-- Set initial selection based on config
local initialSelection = {}
for teamName, isSelected in pairs(Settings.Aim.TargetTeams) do
    if isSelected then
        -- Convert "class-d" to "Class-D" for UI
        local displayName = teamName:gsub("^%l", string.upper):gsub("%-d", "-D")
        table.insert(initialSelection, displayName)
    end
end
TeamSelector:SetValues(initialSelection)

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

FOVBox:AddSlider('FOVScale', {
    Text = 'FOV Scale',
    Default = 1,
    Min = 1,
    Max = 3,
    Rounding = 1,
    Callback = function(val) Settings.FOV.Scale = val end
})

-- Visuals Tab
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

ESPBox:AddToggle('ShowSkeleton', {
    Text = 'Show Skeleton',
    Default = false,
    Callback = function(val) Settings.ESP.ShowSkeleton = val end
})

ESPBox:AddToggle('ShowNames', {
    Text = 'Show Names',
    Default = true,
    Callback = function(val) Settings.ESP.ShowNames = val end
})

ESPBox:AddToggle('ShowTeam', {
    Text = 'Show Team',
    Default = true,
    Callback = function(val) Settings.ESP.ShowTeam = val end
})

ESPBox:AddToggle('ShowDistance', {
    Text = 'Show Distance',
    Default = true,
    Callback = function(val) Settings.ESP.ShowDistance = val end
})

ESPBox:AddToggle('ShowHealth', {
    Text = 'Show Health',
    Default = true,
    Callback = function(val) Settings.ESP.ShowHealth = val end
})

ESPBox:AddToggle('ShowVisibility', {
    Text = 'Show Visibility',
    Default = true,
    Callback = function(val) Settings.ESP.ShowVisibility = val end
})

local ESPCustomBox = Tabs.Visuals:AddRightGroupbox('ESP Customization')
ESPCustomBox:AddSlider('ESPSize', {
    Text = 'Text Size',
    Default = 13,
    Min = 8,
    Max = 20,
    Rounding = 0,
    Callback = function(val) Settings.ESP.Size = val end
})

ESPCustomBox:AddSlider('BoxThickness', {
    Text = 'Box Thickness',
    Default = 1,
    Min = 1,
    Max = 5,
    Rounding = 0,
    Callback = function(val) Settings.ESP.BoxThickness = val end
})

ESPCustomBox:AddLabel('Class-D Color:'):AddColorPicker('ClassDColor', {
    Default = Settings.ESP.ClassDColor,
    Title = 'Class-D ESP Color',
    Callback = function(val) Settings.ESP.ClassDColor = val end
})

ESPCustomBox:AddLabel('Security Color:'):AddColorPicker('SecurityColor', {
    Default = Settings.ESP.SecurityColor,
    Title = 'Security ESP Color',
    Callback = function(val) Settings.ESP.SecurityColor = val end
})

-- Misc Tab
local MiscBox = Tabs.Misc:AddLeftGroupbox('Misc Features')
MiscBox:AddButton('Force Target Lock', function()
    _G.CurrentTarget = _G.GetClosestTarget()
    if _G.CurrentTarget then
        Library:Notify('Locked onto: ' .. _G.CurrentTarget.Name, 2)
    else
        Library:Notify('No target found', 2)
    end
end)

MiscBox:AddButton('Clear Target', function()
    _G.CurrentTarget = nil
    Library:Notify('Target cleared', 2)
end)

MiscBox:AddDivider()
MiscBox:AddToggle('HideCharacter', {
    Text = 'Hide Character',
    Default = false,
    Callback = function(val)
        Settings.Misc.HideCharacter = val
        if LocalPlayer.Character then
            if val then _G.hideCharacter(LocalPlayer.Character)
            else _G.showCharacter(LocalPlayer.Character) end
        end
    end
})

MiscBox:AddToggle('Noclip', {
    Text = 'Noclip (Press N)',
    Default = false,
    Callback = function(val)
        Settings.Misc.Noclip = val
        if val then _G.enableNoclip() else _G.disableNoclip() end
    end
})

MiscBox:AddDivider()
MiscBox:AddToggle('InfiniteJump', {
    Text = 'Infinite Jump',
    Default = false,
    Callback = function(val) Settings.Misc.InfiniteJump = val end
})

MiscBox:AddSlider('JumpPower', {
    Text = 'Jump Power',
    Default = 50,
    Min = 10,
    Max = 150,
    Rounding = 0,
    Callback = function(val) Settings.Misc.JumpPower = val end
})

MiscBox:AddDivider()
MiscBox:AddLabel("Position Hider:")
MiscBox:AddToggle('PositionHiderEnabled', {
    Text = 'Enable Position Hider',
    Default = false,
    Callback = function(val) Settings.PositionHider.Enabled = val end
})

MiscBox:AddToggle('ShowClone', {
    Text = 'Show Fake Clone',
    Default = true,
    Callback = function(val)
        Settings.PositionHider.ShowClone = val
        if not val and _G.visualClone then
            _G.visualClone:Destroy()
            _G.visualClone = nil
        end
    end
})

MiscBox:AddButton('Hide at Current Position', function()
    if Settings.PositionHider.Enabled then
        _G.simpleHideAtPosition()
    else
        Library:Notify("Enable Position Hider first!", 2)
    end
end)

local MiscBox2 = Tabs.Misc:AddRightGroupbox('Visual Enhancements')
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

local DamageBox = Tabs.Misc:AddRightGroupbox('Damage Indicator')
DamageBox:AddToggle('DamageEnabled', {
    Text = 'Enable Damage Indicator',
    Default = false,
    Callback = function(val)
        Settings.Damage.Enabled = val
        if val then _G.enableDamageIndicator() else _G.disableDamageIndicator() end
    end
})

DamageBox:AddToggle('HitSound', {
    Text = 'Hit Sound',
    Default = false,
    Callback = function(val) Settings.Damage.HitSound = val end
})

DamageBox:AddDropdown('HitSoundType', {
    Values = {'Bameware', 'Bell', 'Bubble', 'Pick', 'Pop', 'Rust', 'Skeet', 'Neverlose'},
    Default = 7,
    Multi = false,
    Text = 'Hit Sound Type',
    Callback = function(val) Settings.Damage.HitSoundType = val end
})

DamageBox:AddSlider('HitSoundVolume', {
    Text = 'Hit Sound Volume',
    Default = 50,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Suffix = '%',
    Callback = function(val) Settings.Damage.HitSoundVolume = val / 100 end
})

-- Config Tab
local ConfigBox = Tabs.Config:AddLeftGroupbox('Information')
ConfigBox:AddLabel('SCP Roleplay Framework')
ConfigBox:AddLabel('Version: 1.0')
ConfigBox:AddDivider()
ConfigBox:AddLabel('Team Detection:')
ConfigBox:AddLabel('✓ Class-D vs Security')
ConfigBox:AddLabel('✓ Smart ESP Filtering')
ConfigBox:AddLabel('✓ Auto Team Colors')

-- UI Settings
local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')
MenuGroup:AddButton('Unload', function() Library:Unload() end)

Library.ToggleKeybind = MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', {
    Default = 'End',
    NoUI = true,
    Text = 'Menu keybind'
})

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
ThemeManager:SetFolder('TR4CE_SCP')
SaveManager:SetFolder('TR4CE_SCP/configs')
SaveManager:BuildConfigSection(Tabs['UI Settings'])
ThemeManager:ApplyToTab(Tabs['UI Settings'])

print("[TR4CE] UI loaded")
