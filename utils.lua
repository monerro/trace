--// UTILITIES
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

local Utils = {}

function Utils.IsAlive(player)
    return player and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0
end

function Utils.ShouldTarget(targetPlayer)
    if not _G.Settings.Aimbot.TeamCheck then return true end
    if targetPlayer == LocalPlayer then return false end
    if not targetPlayer.Team or not LocalPlayer.Team then return true end
    return LocalPlayer.Team ~= targetPlayer.Team
end

function Utils.IsADS()
    if not LocalPlayer.Character then return false end
    local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
    return tool and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
end

_G.Utils = Utils
print("[TR4CE] Utilities loaded")
