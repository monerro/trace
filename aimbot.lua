--// AIMBOT SYSTEM - COMPLETE WITH WALL CHECK
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
AimbotStatus.Text = "Aimbot: OFF"
AimbotStatus.Size = 14
AimbotStatus.Color = Color3.fromRGB(255,50,50)
AimbotStatus.Outline = true
AimbotStatus.Center = false
AimbotStatus.Position = Vector2.new(10,10)
AimbotStatus.Visible = true

-- Wall Check System
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
            
            local part = plr.Character and plr.Character:FindFirstChild(Settings.Aim.BodyPart)
            if part then
                local pos, onscreen = Camera:WorldToViewportPoint(part.Position)
                if onscreen then
                    local mag = (Vector2.new(pos.X, pos.Y) - screenCenter).Magnitude
                    if mag < fovRadius and mag < dist then
                        if WallCheck(Camera.CFrame.Position, part) then
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

local CurrentTarget = nil
local aimbotToggled = false
local lastUpdate = 0
local UPDATE_RATE = 1/60

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
    
    if not Settings.Aim.StickyAim or not Utils.IsAlive(CurrentTarget) then
        CurrentTarget = GetClosestTarget()
    end
    
    local shouldAim = false
    if Settings.Aim.HoldMode then
        shouldAim = Settings.Aim.Enabled and UserInputService:IsKeyDown(Settings.Aim.HoldKey)
    else
        shouldAim = Settings.Aim.Enabled and aimbotToggled
    end
    
    if Settings.Aim.ADSOnly then
        shouldAim = shouldAim and Utils.IsADS()
    end
    
    -- Update status text
    if Settings.Aim.Enabled then
        if Settings.Aim.HoldMode then
            if UserInputService:IsKeyDown(Settings.Aim.HoldKey) then
                AimbotStatus.Text = "Aimbot: ACTIVE [HOLD]"
                AimbotStatus.Color = Color3.fromRGB(0,255,0)
            else
                AimbotStatus.Text = "Aimbot: READY [HOLD]"
                AimbotStatus.Color = Color3.fromRGB(255,200,0)
            end
        else
            if aimbotToggled then
                AimbotStatus.Text = "Aimbot: ON [TOGGLE]"
                AimbotStatus.Color = Color3.fromRGB(0,255,0)
            else
                AimbotStatus.Text = "Aimbot: OFF [TOGGLE]"
                AimbotStatus.Color = Color3.fromRGB(255,200,0)
            end
        end
    else
        AimbotStatus.Text = "Aimbot: DISABLED"
        AimbotStatus.Color = Color3.fromRGB(255,50,50)
    end
    
    if shouldAim and CurrentTarget then
        local part = CurrentTarget.Character:FindFirstChild(Settings.Aim.BodyPart)
        if part then
            local camCF = Camera.CFrame
            local targetPos = part.Position
            local direction = (targetPos - camCF.Position).Unit
            local goal = CFrame.new(camCF.Position, camCF.Position + direction)
            Camera.CFrame = camCF:Lerp(goal, Settings.Aim.Smoothness)
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

print("[TR4CE] Aimbot system loaded with wall check")
