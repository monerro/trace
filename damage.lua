--// DAMAGE INDICATOR SYSTEM
local TweenService = _G.TweenService
local Players = _G.Players
local Camera = _G.Camera
local LocalPlayer = _G.LocalPlayer
local Settings = _G.Settings

local DamageIndicatorGui = nil
local trackedPlayers = {}
local damageStack = {}

local function setupDamageGui()
    DamageIndicatorGui = Instance.new("ScreenGui")
    DamageIndicatorGui.Name = "DamageIndicator"
    DamageIndicatorGui.ResetOnSpawn = false
    DamageIndicatorGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    if gethui then
        DamageIndicatorGui.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(DamageIndicatorGui)
        DamageIndicatorGui.Parent = game.CoreGui
    else
        DamageIndicatorGui.Parent = game.CoreGui
    end
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
    
    local sound = Instance.new("Sound")
    sound.SoundId = HitSounds[Settings.Damage.HitSoundType] or HitSounds.Skeet
    sound.Volume = Settings.Damage.HitSoundVolume
    sound.Parent = game:GetService("SoundService")
    sound:Play()
    
    sound.Ended:Connect(function()
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
    label.TextStrokeColor3 = Settings.Damage.OutlineColor
    label.TextTransparency = 0
    label.Parent = DamageIndicatorGui
    
    local screenCenter = Camera.ViewportSize / 2
    local stackOffset = #damageStack * 30
    
    label.Position = UDim2.new(0, screenCenter.X + Settings.Damage.OffsetX - 50, 0, screenCenter.Y + Settings.Damage.OffsetY - 25 + stackOffset)
    
    table.insert(damageStack, label)
    
    local startPos = label.Position
    local endPos = startPos - UDim2.new(0, 0, 0, Settings.Damage.FloatHeight * 30)
    
    local tweenInfo = TweenInfo.new(Settings.Damage.Duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(label, tweenInfo, {
        Position = endPos,
        TextTransparency = 1,
        TextStrokeTransparency = 1
    })
    tween:Play()
    
    if isCritical then
        label.TextSize = Settings.Damage.CriticalSize * 1.5
        local scaleTween = TweenService:Create(label, TweenInfo.new(0.3), {
            TextSize = Settings.Damage.CriticalSize
        })
        scaleTween:Play()
    end
    
    task.delay(Settings.Damage.Duration, function()
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
                if _G.CurrentTarget == targetPlayer then
                    local damage = lastHealth - newHealth
                    local isCritical = damage >= Settings.Damage.CriticalThreshold
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
        DamageIndicatorGui:ClearAllChildren()
    end
    damageStack = {}
end

-- Connect to settings
_G.enableDamageIndicator = enableDamageIndicator
_G.disableDamageIndicator = disableDamageIndicator

print("[TR4CE] Damage indicator system loaded")
