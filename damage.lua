--// DAMAGE INDICATOR SYSTEM - AIMBOT ONLY VERSION

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Wait for Settings to load
local Settings = _G.Settings
if not Settings then
    for i = 1, 30 do
        if _G.Settings then
            Settings = _G.Settings
            break
        end
        task.wait(0.1)
    end
    if not Settings then
        Settings = {}
        _G.Settings = Settings
    end
end

-- Ensure Damage settings exist
if not Settings.Damage then 
    Settings.Damage = {
        Enabled = false,
        HitSound = false,
        HitSoundType = "Skeet",
        HitSoundVolume = 0.5,
        AimbotOnly = true  -- TRUE = only aimbot hits
    }
end

local DamageIndicatorGui = nil
local damageStack = {}
local trackingConnection = nil

-- Hit sounds
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

local function setupDamageGui()
    if DamageIndicatorGui then 
        DamageIndicatorGui:Destroy() 
        DamageIndicatorGui = nil
    end
    
    DamageIndicatorGui = Instance.new("ScreenGui")
    DamageIndicatorGui.Name = "DamageIndicator"
    DamageIndicatorGui.ResetOnSpawn = false
    DamageIndicatorGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    if gethui then
        DamageIndicatorGui.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(DamageIndicatorGui)
        DamageIndicatorGui.Parent = game:GetService("CoreGui")
    else
        DamageIndicatorGui.Parent = game:GetService("CoreGui")
    end
end

local function playHitSound()
    if not Settings.Damage.HitSound then return end
    
    local soundId = HitSounds[Settings.Damage.HitSoundType] or HitSounds.Skeet
    
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
    label.TextSize = isCritical and 32 or 24
    label.TextColor3 = isCritical and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(255, 255, 255)
    label.TextStrokeTransparency = 0.5
    label.TextStrokeColor3 = Color3.new(0,0,0)
    label.TextTransparency = 0
    label.Parent = DamageIndicatorGui
    
    local screenCenter = Camera.ViewportSize / 2
    local stackOffset = #damageStack * 30
    
    label.Position = UDim2.new(
        0, screenCenter.X + 50, 
        0, screenCenter.Y - 25 + stackOffset
    )
    
    table.insert(damageStack, label)
    
    local startPos = label.Position
    local endPos = startPos - UDim2.new(0, 0, 0, 60)
    
    local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(label, tweenInfo, {
        Position = endPos,
        TextTransparency = 1,
        TextStrokeTransparency = 1
    })
    tween:Play()
    
    task.delay(2, function()
        for i, v in ipairs(damageStack) do
            if v == label then
                table.remove(damageStack, i)
                break
            end
        end
        label:Destroy()
    end)
end

-- 🎯 KEY FIX: Track ONLY the aimbot target's damage
local function trackAimbotTargetDamage()
    if trackingConnection then
        trackingConnection:Disconnect()
        trackingConnection = nil
    end
    
    -- Function to check and track current target
    local function checkCurrentTarget()
        local currentTarget = _G.CurrentTarget
        
        -- If we have a target and aimbot is active, track their damage
        if currentTarget and currentTarget.Character then
            local humanoid = currentTarget.Character:FindFirstChild("Humanoid")
            if humanoid then
                local lastHealth = humanoid.Health
                
                trackingConnection = humanoid.HealthChanged:Connect(function(newHealth)
                    if newHealth < lastHealth then
                        local damage = lastHealth - newHealth
                        
                        -- Check if aimbot is ACTIVE (not just enabled)
                        local isAimbotActive = false
                        if Settings.Aim and Settings.Aim.Enabled then
                            if Settings.Aim.HoldMode then
                                isAimbotActive = UserInputService:IsKeyDown(Settings.Aim.HoldKey or Enum.KeyCode.E)
                            else
                                isAimbotActive = _G.aimbotToggled or false
                            end
                        end
                        
                        -- Only show damage if aimbot is actively aiming OR if AimbotOnly is false
                        if (not Settings.Damage.AimbotOnly) or isAimbotActive then
                            local isCritical = damage >= 50
                            createDamageLabel(damage, isCritical)
                        end
                    end
                    lastHealth = newHealth
                end)
                
                print("[TR4CE] Now tracking damage for aimbot target: " .. currentTarget.Name)
            end
        end
    end
    
    -- Run initial check
    checkCurrentTarget()
    
    -- Also check when CurrentTarget changes
    local targetCheckConnection
    targetCheckConnection = RunService.Heartbeat:Connect(function()
        local oldTarget = _G.LastTrackedTarget
        local newTarget = _G.CurrentTarget
        
        if oldTarget ~= newTarget then
            if trackingConnection then
                trackingConnection:Disconnect()
                trackingConnection = nil
            end
            checkCurrentTarget()
            _G.LastTrackedTarget = newTarget
        end
    end)
    
    return targetCheckConnection
end

local function enableDamageIndicator()
    if not DamageIndicatorGui then
        setupDamageGui()
    end
    
    print("[TR4CE] Damage system: AimbotOnly = " .. tostring(Settings.Damage.AimbotOnly))
    
    -- Start tracking aimbot target damage
    _G.damageTracker = trackAimbotTargetDamage()
    
    -- If AimbotOnly is FALSE, also track all players (old behavior)
    if not Settings.Damage.AimbotOnly then
        print("[TR4CE] WARNING: Tracking ALL player damage (AimbotOnly = false)")
    end
end

local function disableDamageIndicator()
    if _G.damageTracker then
        _G.damageTracker:Disconnect()
        _G.damageTracker = nil
    end
    
    if trackingConnection then
        trackingConnection:Disconnect()
        trackingConnection = nil
    end
    
    if DamageIndicatorGui then
        DamageIndicatorGui:Destroy()
        DamageIndicatorGui = nil
    end
    
    damageStack = {}
end

-- Export functions
_G.enableDamageIndicator = enableDamageIndicator
_G.disableDamageIndicator = disableDamageIndicator
_G.createDamageLabel = createDamageLabel

print("[TR4CE] Damage system loaded - Aimbot hits only: " .. tostring(Settings.Damage.AimbotOnly))
