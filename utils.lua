--// UTILITY FUNCTIONS
local Players = _G.Players
local LocalPlayer = _G.LocalPlayer
local UserInputService = _G.UserInputService

local Utils = {}

function Utils.getHRP()
    if LocalPlayer.Character then
        return LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    end
end

function Utils.IsAlive(player)
    if not player then return false end
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
    
    if myTeamName:match("class%-d") or myTeamName:match("class d") then
        return theirTeamName:match("security") or theirTeamName:match("rapid response") or 
               theirTeamName:match("mobile task force") or theirTeamName:match("internal security")
    end
    
    if myTeamName:match("chaos") then
        return theirTeamName:match("security") or theirTeamName:match("rapid response") or 
               theirTeamName:match("mobile task force") or theirTeamName:match("internal security")
    end
    
    if myTeamName:match("security department") then
        return theirTeamName:match("class%-d") or theirTeamName:match("class d") or theirTeamName:match("chaos")
    end
    
    if myTeamName:match("rapid response") then
        return theirTeamName:match("class%-d") or theirTeamName:match("class d") or theirTeamName:match("chaos")
    end
    
    if myTeamName:match("mobile task force") then
        return theirTeamName:match("class%-d") or theirTeamName:match("class d") or theirTeamName:match("chaos")
    end
    
    if myTeamName:match("internal security") then
        return theirTeamName:match("class%-d") or theirTeamName:match("class d") or theirTeamName:match("chaos")
    end
    
    if myTeamName:match("scientific") or myTeamName:match("medical") or myTeamName:match("administrative") then
        return false
    end
    
    return true
end

function Utils.IsADS()
    if not LocalPlayer.Character then return false end
    
    local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if tool then
        if tool:FindFirstChild("Handle") then
            if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
                return true
            end
            
            local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
            if humanoid then
                for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                    local animName = track.Animation.Name:lower()
                    if animName:find("aim") or animName:find("ads") or animName:find("iron") then
                        return true
                    end
                end
            end
        end
    end
    
    local camera = workspace.CurrentCamera
    if camera then
        if camera.FieldOfView < 70 then
            return true
        end
    end
    
    return false
end

_G.Utils = Utils
print("[TR4CE] Utility functions loaded")
