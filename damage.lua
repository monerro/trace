--// SIMPLE DAMAGE INDICATOR (NO HITSOUNDS)
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local DamageIndicatorGui = nil
local damageStack = {}

local function setupDamageGui()
    if DamageIndicatorGui then 
        DamageIndicatorGui:Destroy() 
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

-- Export this function for aimbot to call
_G.createDamageLabel = function(damage, isCritical)
    if not DamageIndicatorGui then setupDamageGui() end
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 100, 0, 50)
    label.BackgroundTransparency = 1
    label.Text = "-" .. math.floor(damage)
    label.Font = Enum.Font.GothamBold
    label.TextSize = isCritical and 32 or 24
    label.TextColor3 = isCritical and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(255, 255, 255)
    label.TextStrokeTransparency = 0.5
    label.TextStrokeColor3 = Color3.new(0,0,0)
    label.TextTransparency = 0
    label.Parent = DamageIndicatorGui
    
    local screenCenter = Camera.ViewportSize / 2
    local stackOffset = #damageStack * 30
    
    label.Position = UDim2.new(0, screenCenter.X + 50, 0, screenCenter.Y - 25 + stackOffset)
    
    table.insert(damageStack, label)
    
    local endPos = label.Position - UDim2.new(0, 0, 0, 60)
    local tween = TweenService:Create(label, TweenInfo.new(2), {
        Position = endPos,
        TextTransparency = 1,
        TextStrokeTransparency = 1
    })
    tween:Play()
    
    task.delay(2, function()
        for i, v in ipairs(damageStack) do
            if v == label then table.remove(damageStack, i) break end
        end
        label:Destroy()
    end)
end

-- Simple enable/disable
_G.enableDamageIndicator = setupDamageGui
_G.disableDamageIndicator = function()
    if DamageIndicatorGui then
        DamageIndicatorGui:Destroy()
        DamageIndicatorGui = nil
    end
    damageStack = {}
end

print("[TR4CE] Simple damage indicator loaded")
