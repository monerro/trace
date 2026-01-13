--// AIMBOT SYSTEM
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Import settings
local Settings = _G.Settings

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Filled = false
FOVCircle.Color = Color3.fromRGB(255,255,255)
FOVCircle.Transparency = 0.9

-- Rest of aimbot code...
-- (Copy your aimbot section here, starting from line with "local FOVCircle = Drawing.new...")

return {
    FOVCircle = FOVCircle,
    GetClosestTarget = GetClosestTarget,
    CurrentTarget = CurrentTarget
}
