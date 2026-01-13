--// MISC FEATURES
local RunService = _G.RunService
local UserInputService = _G.UserInputService
local Players = _G.Players
local TweenService = _G.TweenService
local LocalPlayer = _G.LocalPlayer
local Lighting = _G.Lighting
local Settings = _G.Settings
local Library = _G.Library

-- Position Hider
local simpleHideEnabled = false
local savedPosition = nil
local savedCFrame = nil
local visualClone = nil
local originalTransparency = {}
local characterHidden = false

local function createVisualClone()
    if visualClone then visualClone:Destroy() end
    
    visualClone = Instance.new("Model")
    visualClone.Name = "PositionHiderClone"
    
    if LocalPlayer.Character then
        for _, child in pairs(LocalPlayer.Character:GetChildren()) do
            if child:IsA("BasePart") or child:IsA("MeshPart") or child:IsA("Part") then
                local clone = child:Clone()
                clone.CanCollide = false
                clone.Anchored = true
                clone.Parent = visualClone
                
                if clone:IsA("BasePart") then
                    clone.Transparency = 0.5
                    clone.Material = Enum.Material.Neon
                    clone.Color = Settings.PositionHider.CloneColor
                end
            elseif child:IsA("Accessory") then
                local clone = child:Clone()
                for _, part in pairs(clone:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                        part.Anchored = true
                    end
                end
                clone.Parent = visualClone
            end
        end
    end
    
    visualClone.Parent = workspace
    
    local highlight = Instance.new("Highlight")
    highlight.Adornee = visualClone
    highlight.FillColor = Settings.PositionHider.CloneColor
    highlight.FillTransparency = 0.7
    highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
    highlight.Parent = visualClone
    
    return visualClone
end

local function hideRealCharacter()
    if not LocalPlayer.Character or characterHidden then return end
    
    characterHidden = true
    originalTransparency = {}
    
    for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
        if part:IsA("BasePart") then
            originalTransparency[part] = part.Transparency
            part.LocalTransparencyModifier = 1
            part.Transparency = 1
        elseif part:IsA("Decal") or part:IsA("Texture") then
            originalTransparency[part] = part.Transparency
            part.Transparency = 1
        end
    end
end

local function showRealCharacter()
    if not LocalPlayer.Character or not characterHidden then return end
    
    characterHidden = false
    
    for obj, transparency in pairs(originalTransparency) do
        if obj and obj.Parent then
            obj.Transparency = transparency
            if obj:IsA("BasePart") then
                obj.LocalTransparencyModifier = 0
            end
        end
    end
    
    originalTransparency = {}
end

function simpleHideAtPosition()
    if not LocalPlayer.Character then 
        Library:Notify("No character found!", 2)
        return 
    end
    
    local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then 
        Library:Notify("No HumanoidRootPart found!", 2)
        return 
    end
    
    if not simpleHideEnabled then
        savedPosition = hrp.Position
        savedCFrame = hrp.CFrame
        simpleHideEnabled = true
        
        hideRealCharacter()
        
        if Settings.PositionHider.ShowClone then
            createVisualClone()
            if visualClone then
                visualClone:SetPrimaryPartCFrame(savedCFrame)
            end
        end
        
        Library:Notify("✓ Hidden at position! You are invisible and can move.", 3)
    else
        simpleHideEnabled = false
        showRealCharacter()
        
        hrp.CFrame = savedCFrame
        
        if visualClone then
            visualClone:Destroy()
            visualClone = nil
        end
        
        Library:Notify("✓ Returned to position!", 3)
    end
end

-- Noclip
local noclipConnection = nil

function enableNoclip()
    if noclipConnection then return end
    
    noclipConnection = RunService.Stepped:Connect(function()
        if Settings.Misc.Noclip and LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end

function disableNoclip()
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    
    if LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

-- Character Hiding
local function hideCharacter(character)
    for _, obj in pairs(character:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.LocalTransparencyModifier = 1
        elseif obj:IsA("Decal") then
            obj.Transparency = 1
        end
    end
end

local function showCharacter(character)
    for _, obj in pairs(character:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.LocalTransparencyModifier = 0
        elseif obj:IsA("Decal") then
            obj.Transparency = 0
        end
    end
end

local function onCharacterAdded(character)
    task.wait(0.5)
    if Settings.Misc.HideCharacter then
        hideCharacter(character)
    end
end

if LocalPlayer.Character then
    onCharacterAdded(LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

-- Fullbright
local originalBrightness = Lighting.Brightness
local originalClockTime = Lighting.ClockTime
local originalOutdoorAmbient = Lighting.OutdoorAmbient
local originalFogEnd = Lighting.FogEnd

function EnableFullbright()
    Lighting.Brightness = 2
    Lighting.ClockTime = 14
    Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    Lighting.FogEnd = 100000
    Lighting.GlobalShadows = false
    
    for _, descendant in pairs(Lighting:GetDescendants()) do
        if descendant:IsA("DepthOfFieldEffect") then
            descendant.Enabled = false
        end
    end
end

function DisableFullbright()
    Lighting.Brightness = originalBrightness
    Lighting.ClockTime = originalClockTime
    Lighting.OutdoorAmbient = originalOutdoorAmbient
    Lighting.FogEnd = originalFogEnd
    Lighting.GlobalShadows = true
end

-- Infinite Jump
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or not Settings.Misc.InfiniteJump then return end
    
    if input.KeyCode == Enum.KeyCode.Space and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.JumpPower = Settings.Misc.JumpPower
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- Position Hider Keybind
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Settings.PositionHider.ToggleKey and Settings.PositionHider.Enabled then
        simpleHideAtPosition()
    end
end)

-- Noclip Keybind
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Settings.Misc.NoclipKey then
        Settings.Misc.Noclip = not Settings.Misc.Noclip
        if Settings.Misc.Noclip then
            enableNoclip()
        else
            disableNoclip()
        end
    end
end)

-- Export functions
_G.simpleHideAtPosition = simpleHideAtPosition
_G.enableNoclip = enableNoclip
_G.disableNoclip = disableNoclip
_G.EnableFullbright = EnableFullbright
_G.DisableFullbright = DisableFullbright

print("[TR4CE] Misc features loaded")
