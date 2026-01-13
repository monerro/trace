--// RAW AIMLOCK - ZERO SMOOTHNESS, HEAD SNAP
local RunService = _G.RunService
local UserInputService = _G.UserInputService
local Players = _G.Players
local Camera = _G.Camera
local LocalPlayer = _G.LocalPlayer
local Settings = _G.Settings
local Utils = _G.Utils

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Filled = false
FOVCircle.Color = Color3.fromRGB(255,255,255)
FOVCircle.Transparency = 0.9

-- Aimbot Status
local AimbotStatus = Drawing.new("Text")
AimbotStatus.Text = "AIMLOCK: OFF"
AimbotStatus.Size = 14
AimbotStatus.Color = Color3.fromRGB(255,50,50)
AimbotStatus.Outline = true
AimbotStatus.Center = false
AimbotStatus.Position = Vector2.new(10,10)
AimbotStatus.Visible = true

-- Wall Check (optional)
local wallCheckParams = RaycastParams.new()
wallCheckParams.FilterType = Enum.RaycastFilterType.Blacklist
wallCheckParams.IgnoreWater = true

local function WallCheck(origin, targetPart)
    if not Settings.Aim.WallCheck then return true end
    
    wallCheckParams.FilterDescendantsInstances = {LocalPlayer.Character}
    
    local direction = (targetPart.Position - origin)
    local ray = workspace:Raycast(origin, direction, wallCheckParams)
    
    if ray then
        local hit = ray.Instance
        if hit:IsDescendantOf(targetPart.Parent) then
            return true
        end
        return false
    end
    
    return true
end

-- Get closest target
local function GetClosestTarget()
    local closest, dist = nil, math.huge
    local screenCenter = Camera.ViewportSize / 2
    local fovRadius = Settings.FOV.Radius * Settings.FOV.Scale
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr and plr ~= LocalPlayer and Utils.IsAlive(plr) then
            -- Team check
            if Settings.Aim.TeamCheck then
                if Settings.Aim.CustomTeams then
                    if not Utils.ShouldTargetCustom(plr) then continue end
                else
                    if not Utils.IsHostileTeam(plr) then continue end
                end
            end
            
            local head = plr.Character and plr.Character:FindFirstChild("Head")
            if head then
                local pos, onscreen = Camera:WorldToViewportPoint(head.Position)
                if onscreen then
                    local mag = (Vector2.new(pos.X, pos.Y) - screenCenter).Magnitude
                    if mag < fovRadius and mag < dist then
                        if WallCheck(Camera.CFrame.Position, head) then
                            dist = mag
                            closest = plr
                        end
                    end
                end
            end
        end
    end
    return closest
end

-- 🎯 SPAM HITSOUND SYSTEM
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

local hitSoundQueue = {}
local isPlayingSound = false

local function playHitSound()
    if not Settings.Damage or not Settings.Damage.HitSound then return end
    
    table.insert(hitSoundQueue, tick())
    
    if not isPlayingSound then
        isPlayingSound = true
        
        local soundId = HitSounds[Settings.Damage.HitSoundType] or HitSounds.Skeet
        
        local sound = Instance.new("Sound")
        sound.SoundId = soundId
        sound.Volume = Settings.Damage.HitSoundVolume or 0.5
        sound.Parent = game:GetService("SoundService")
        sound:Play()
        
        sound.Ended:Once(function()
            sound:Destroy()
            isPlayingSound = false
            
            -- Play next sound in queue if there is one
            if #hitSoundQueue > 0 then
                table.remove(hitSoundQueue, 1)
                playHitSound()
            end
        end)
    end
end

-- Check for damage to trigger hitsound spam
local function checkForDamage()
    if not CurrentTarget then return end
    if not CurrentTarget.Character then return end
    
    local humanoid = CurrentTarget.Character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    local currentHealth = humanoid.Health
    local lastHealth = targetLastHealth[CurrentTarget] or currentHealth
    
    -- Check if health decreased
    if currentHealth < lastHealth then
        local damage = lastHealth - currentHealth
        
        -- Spam hitsounds based on damage
        local soundCount = math.min(math.floor(damage / 5), 10)
        for i = 1, soundCount do
            task.spawn(playHitSound)
        end
    end
    
    targetLastHealth[CurrentTarget] = currentHealth
end

-- Main variables
local CurrentTarget = nil
local aimbotToggled = false
local targetLastHealth = {}
local lastUpdate = 0
local UPDATE_RATE = 1/144  -- Max FPS

RunService.RenderStepped:Connect(function()
    local now = tick()
    
    FOVCircle.Visible = Settings.FOV.Enabled and Settings.FOV.DrawCircle
    if FOVCircle.Visible then
        local screenCenter = Camera.ViewportSize / 2
        FOVCircle.Position = screenCenter
        FOVCircle.Radius = Settings.FOV.Radius * Settings.FOV.Scale
    end
    
    if now - lastUpdate < UPDATE_RATE then return end
    lastUpdate = now
    
    -- Always update target for sticky tracking
    CurrentTarget = GetClosestTarget()
    
    local shouldAim = false
    if Settings.Aim.HoldMode then
        shouldAim = Settings.Aim.Enabled and UserInputService:IsKeyDown(Settings.Aim.HoldKey)
    else
        shouldAim = Settings.Aim.Enabled and aimbotToggled
    end
    
    if Settings.Aim.ADSOnly then
        shouldAim = shouldAim and Utils.IsADS()
    end
    
    -- Update status
    if Settings.Aim.Enabled then
        if shouldAim then
            AimbotStatus.Text = "AIMLOCK: ON"
            AimbotStatus.Color = Color3.fromRGB(0,255,0)
        else
            AimbotStatus.Text = "AIMLOCK: READY"
            AimbotStatus.Color = Color3.fromRGB(255,200,0)
        end
    else
        AimbotStatus.Text = "AIMLOCK: DISABLED"
        AimbotStatus.Color = Color3.fromRGB(255,50,50)
    end
    
    -- 🎯 RAW AIMLOCK (ZERO SMOOTHNESS)
    if shouldAim and CurrentTarget then
        local head = CurrentTarget.Character:FindFirstChild("Head")
        if head then
            -- DIRECT HEAD SNAP - NO SMOOTHNESS
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, head.Position)
            
            -- Check for damage and spam hitsounds
            checkForDamage()
        end
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Settings.Aim.HoldKey and not Settings.Aim.HoldMode then
        aimbotToggled = not aimbotToggled
    end
end)

-- Export
_G.CurrentTarget = CurrentTarget
_G.GetClosestTarget = GetClosestTarget
_G.aimbotToggled = aimbotToggled

print("[TR4CE] RAW AIMLOCK loaded - Zero smoothness head tracking")
