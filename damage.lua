--// DAMAGE INDICATOR SYSTEM - FIXED VERSION

local function waitForDependency(name)
    for i = 1, 50 do  -- 5 second timeout
        if _G[name] ~= nil then
            return _G[name]
        end
        task.wait(0.1)
    end
    return nil
end

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Settings = _G.Settings or {}
local DamageIndicatorGui = nil
local trackedPlayers = {}
local damageStack = {}

-- Ensure Settings.Damage exists
if not Settings.Damage then 
    Settings.Damage = {
        Enabled = false,
        HitSound = false,
        HitSoundType = "Skeet",
        HitSoundVolume = 0.5,
        TextSize = 18,
        CriticalSize = 24,
        NormalColor = Color3.fromRGB(255, 255, 255),
        CriticalColor = Color3.fromRGB(255, 50, 50),
        OutlineColor = Color3.fromRGB(0, 0, 0),
        Duration = 2,
        FloatHeight = 2,
        OffsetX = 0,
        OffsetY = 0,
        AimbotOnly = true  -- NEW: Only play for aimbot hits
    }
end

-- These need to be accessed from main script
local function getCurrentTarget()
    return _G.CurrentTarget or nil
end

local function isAimbotActive()
    -- Check main script's aimbot state
    if Settings.Aim and Settings.Aim.Enabled then
        if Settings.Aim.HoldMode then
            return UserInputService:IsKeyDown(Settings.Aim.HoldKey or Enum.KeyCode.E)
        else
            return _G.aimbotToggled or false
        end
    end
    return false
end

local function setupDamageGui()
    if DamageIndicatorGui then 
        DamageIndicatorGui:Destroy() 
        DamageIndicatorGui = nil
    end
    
    DamageIndicatorGui = Instance.new("ScreenGui")
    DamageIndicatorGui.Name = "DamageIndicator"
    DamageIndicatorGui.ResetOnSpawn = false
    DamageIndicatorGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Parent to appropriate GUI
    if gethui then
        DamageIndicatorGui.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(DamageIndicatorGui)
        DamageIndicatorGui.Parent = game:GetService("CoreGui")
    else
        DamageIndicatorGui.Parent = game:GetService("CoreGui")
    end
    
    print("[TR4CE] Damage GUI created")
end

local HitSounds = {
    Bameware = "rbxassetid://3124331820",
    Bell = "rbxassetid://6534947240",
    Bubble = "rbxassetid://6534947588",
    Pick = "rbxassetid://1347140027",
    Pop = "rbxassetid://198598793",
    Rust = "rbxassetid://1255040462",
    Skeet = "rbxassetid://5447626464",
    Neverlose = "rbxassetid://6534947588"
}

local function playHitSound()
    if not Settings.Damage.HitSound then return end
    
    local soundId = HitSounds[Settings.Damage.HitSoundType] 
    if not soundId then soundId = HitSounds.Skeet end
    
    local sound = Instance.new("Sound")
    sound.SoundId = soundId
    sound.Volume = Settings.Damage.HitSoundVolume or 0.5
    sound.Parent = game:GetService("SoundService")
    sound:Play()
    
    sound.Ended:Once(function()
        sound:Destroy()
    end)
end

local function createDamageLabel(damage, isCritical)
    if not Settings.Damage.Enabled or not DamageIndicatorGui then return end
    
    playHitSound()

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 100, 0, 50)
    label.BackgroundTransparency = 1
    label.Text = "-" .. tostring(math.floor(damage))
    label.Font = Enum.Font.GothamBold
    label.TextSize = isCritical and Settings.Damage.CriticalSize or Settings.Damage.TextSize
    label.TextColor3 = isCritical and Settings.Damage.CriticalColor or Settings.Damage.NormalColor
    label.TextStrokeTransparency = 0.5
    label.TextStrokeColor3 = Settings.Damage.OutlineColor or Color3.new(0,0,0)
    label.TextTransparency = 0
    label.Parent = DamageIndicatorGui
    
    local screenCenter = Camera.ViewportSize / 2
    local stackOffset = #damageStack * 30
    
    label.Position = UDim2.new(
        0, screenCenter.X + (Settings.Damage.OffsetX or 0) - 50, 
        0, screenCenter.Y + (Settings.Damage.OffsetY or 0) - 25 + stackOffset
    )
    
    table.insert(damageStack, label)
    
    local startPos = label.Position
    local endPos = startPos - UDim2.new(0, 0, 0, (Settings.Damage.FloatHeight or 2) * 30)
    
    local tweenInfo = TweenInfo.new(Settings.Damage.Duration or 2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(label, tweenInfo, {
        Position = endPos,
        TextTransparency = 1,
        TextStrokeTransparency = 1
    })
    tween:Play()
    
    if isCritical then
        task.spawn(function()
            local scaleTween = TweenService:Create(label, TweenInfo.new(0.3), {
                TextSize = (Settings.Damage.CriticalSize or 24) * 1.2
            })
            scaleTween:Play()
            task.wait(0.1)
            scaleTween = TweenService:Create(label, TweenInfo.new(0.2), {
                TextSize = Settings.Damage.CriticalSize or 24
            })
            scaleTween:Play()
        end)
    end
    
    task.delay(Settings.Damage.Duration or 2, function()
        for i, v in ipairs(damageStack) do
            if v == label then
                table.remove(damageStack, i)
                break
            end
        end
        label:Destroy()
    end)
end

local function trackPlayerForDamage(targetPlayer)
    if trackedPlayers[targetPlayer] then return end
    if targetPlayer == LocalPlayer then return end
    
    local function onCharacterAdded(character)
        local humanoid = character:WaitForChild("Humanoid", 5)
        if not humanoid then return end
        
        local lastHealth = humanoid.Health
        
        local connection = humanoid.HealthChanged:Connect(function(newHealth)
            if newHealth < lastHealth then
                local damage = lastHealth - newHealth
                local shouldPlaySound = true
                
                -- CHECK: Only play for aimbot hits if AimbotOnly is enabled
                if Settings.Damage.AimbotOnly then
                    local currentTarget = getCurrentTarget()
                    local isAimbotActiveNow = isAimbotActive()
                    
                    shouldPlaySound = (currentTarget == targetPlayer) and isAimbotActiveNow
                    
                    -- Debug output
                    if shouldPlaySound then
                        print("[TR4CE] Aimbot hit detected: " .. targetPlayer.Name .. " -" .. damage .. "HP")
                    end
                end
                
                if shouldPlaySound then
                    local isCritical = damage >= (Settings.Damage.CriticalThreshold or 50)
                    createDamageLabel(damage, isCritical)
                end
            end
            lastHealth = newHealth
        end)
        
        trackedPlayers[targetPlayer] = connection
        
        character.AncestryChanged:Connect(function()
            if connection then
                connection:Disconnect()
            end
            trackedPlayers[targetPlayer] = nil
        end)
    end
    
    if targetPlayer.Character then
        onCharacterAdded(targetPlayer.Character)
    end
    
    targetPlayer.CharacterAdded:Connect(onCharacterAdded)
end

local function enableDamageIndicator()
    if not DamageIndicatorGui then
        setupDamageGui()
    end
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            trackPlayerForDamage(plr)
        end
    end
    
    Players.PlayerAdded:Connect(function(plr)
        trackPlayerForDamage(plr)
    end)
    
    Players.PlayerRemoving:Connect(function(plr)
        if trackedPlayers[plr] then
            trackedPlayers[plr]:Disconnect()
            trackedPlayers[plr] = nil
        end
    end)
end

local function disableDamageIndicator()
    for plr, connection in pairs(trackedPlayers) do
        if connection then
            connection:Disconnect()
        end
    end
    trackedPlayers = {}
    
    if DamageIndicatorGui then
        DamageIndicatorGui:Destroy()
        DamageIndicatorGui = nil
    end
    damageStack = {}
end

-- Export to _G so main script can access
_G.enableDamageIndicator = enableDamageIndicator
_G.disableDamageIndicator = disableDamageIndicator
_G.createDamageLabel = createDamageLabel

-- Add these to your main script too!
_G.trackPlayerForDamage = trackPlayerForDamage

print("[TR4CE] Damage indicator system loaded with aimbot-only hits")
