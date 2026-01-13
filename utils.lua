--// UTILITY FUNCTIONS
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Utils = {}

function Utils.getHRP()
    if LocalPlayer.Character then
        return LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    end
end

function Utils.IsAlive(player)
    local c = player.Character
    return c and c:FindFirstChild("Humanoid") and c.Humanoid.Health > 0
end

function Utils.IsHostileTeam(targetPlayer)
    if not targetPlayer or not LocalPlayer then return false end
    if targetPlayer == LocalPlayer then return false end
    
    if not targetPlayer.Team or not LocalPlayer.Team then return false end
    
    local myTeam = LocalPlayer.Team
    local theirTeam = targetPlayer.Team
    
    if myTeam == theirTeam then return false end
    
    local myTeamName = myTeam.Name:lower()
    local theirTeamName = theirTeam.Name:lower()
    
    -- Team detection logic...
    -- (Copy your existing IsHostileTeam function here)
    
    return true
end

return Utils
