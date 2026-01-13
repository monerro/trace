--// ESP SYSTEM - COMPLETE WITH SKELETON
local RunService = _G.RunService
local Players = _G.Players
local Camera = _G.Camera
local LocalPlayer = _G.LocalPlayer
local Settings = _G.Settings
local Utils = _G.Utils

local ESPObjects = {}
local visibilityCache = {}
local VISIBILITY_UPDATE_RATE = 0.5

local function IsVisible(character)
    if not character or not LocalPlayer.Character then return false end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local myHrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp or not myHrp then return false end
    
    local cacheKey = character
    if visibilityCache[cacheKey] and tick() - visibilityCache[cacheKey].time < VISIBILITY_UPDATE_RATE then
        return visibilityCache[cacheKey].visible
    end
    
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {LocalPlayer.Character, character}
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.IgnoreWater = true
    
    local direction = (hrp.Position - myHrp.Position)
    local ray = workspace:Raycast(myHrp.Position, direction, params)
    
    local visible = ray == nil
    visibilityCache[cacheKey] = {visible = visible, time = tick()}
    
    return visible
end

local function CreateESP(plr)
    local esp = {
        text = Drawing.new("Text"),
        statusText = Drawing.new("Text"),
        box = Drawing.new("Square"),
        skeleton = {}
    }
    
    esp.text.Center = true
    esp.text.Outline = true
    esp.text.Size = Settings.ESP.Size
    
    esp.statusText.Center = true
    esp.statusText.Outline = true
    esp.statusText.Size = Settings.ESP.Size - 2
    
    esp.box.Thickness = Settings.ESP.BoxThickness
    esp.box.Filled = false
    
    -- Skeleton lines
    local skeletonParts = {
        {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
        {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"},
        {"LeftLowerArm", "LeftHand"}, {"UpperTorso", "RightUpperArm"},
        {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
        {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"},
        {"LeftLowerLeg", "LeftFoot"}, {"LowerTorso", "RightUpperLeg"},
        {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}
    }
    
    for i = 1, #skeletonParts do
        local line = Drawing.new("Line")
        line.Thickness = Settings.ESP.SkeletonThickness
        esp.skeleton[i] = line
    end
    
    ESPObjects[plr] = esp
end

local function RemoveESP(plr)
    if ESPObjects[plr] then
        ESPObjects[plr].text:Remove()
        ESPObjects[plr].statusText:Remove()
        ESPObjects[plr].box:Remove()
        for _, line in pairs(ESPObjects[plr].skeleton) do
            line:Remove()
        end
        ESPObjects[plr] = nil
    end
    visibilityCache[plr] = nil
end

-- Initialize ESP for all players
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then CreateESP(p) end
end

Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)

local lastESPUpdate = 0
local ESP_UPDATE_RATE = 1/60

RunService.RenderStepped:Connect(function()
    if not Settings.ESP.Enabled then
        for _, esp in pairs(ESPObjects) do
            esp.text.Visible = false
            esp.statusText.Visible = false
            esp.box.Visible = false
            for _, line in pairs(esp.skeleton) do line.Visible = false end
        end
        return
    end
    
    local now = tick()
    if now - lastESPUpdate < ESP_UPDATE_RATE then return end
    lastESPUpdate = now
    
    for plr, esp in pairs(ESPObjects) do
        if Utils.IsAlive(plr) then
            if Settings.ESP.TeamCheck and not Utils.IsHostileTeam(plr) then
                esp.text.Visible = false
                esp.statusText.Visible = false
                esp.box.Visible = false
                for _, line in pairs(esp.skeleton) do line.Visible = false end
                continue
            end
            
            local character = plr.Character
            local hrp = character:FindFirstChild("HumanoidRootPart")
            local head = character:FindFirstChild("Head")
            local humanoid = character:FindFirstChild("Humanoid")
            
            if hrp and head and humanoid then
                local hrpPos, hrpOnScreen = Camera:WorldToViewportPoint(hrp.Position)
                
                if hrpOnScreen then
                    local isVisible = IsVisible(character)
                    local espColor = isVisible and Settings.ESP.VisibleColor or Settings.ESP.HiddenColor
                    
                    -- Team-based coloring
                    if Utils.IsHostileTeam(plr) then
                        local teamName = plr.Team and plr.Team.Name:lower() or ""
                        if teamName:match("class") and teamName:match("d") then
                            espColor = isVisible and Settings.ESP.ClassDColor or Color3.fromRGB(180, 100, 0)
                        elseif teamName:match("security") or teamName:match("guard") or teamName:match("mtf") then
                            espColor = isVisible and Settings.ESP.SecurityColor or Color3.fromRGB(0, 60, 180)
                        end
                    end
                    
                    local dist = 0
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        dist = (hrp.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                    end
                    
                    -- Text info
                    local textParts = {}
                    if Settings.ESP.ShowNames then table.insert(textParts, plr.Name) end
                    if Settings.ESP.ShowTeam and plr.Team then table.insert(textParts, plr.Team.Name) end
                    if Settings.ESP.ShowDistance then table.insert(textParts, string.format("[%dm]", math.floor(dist))) end
                    if Settings.ESP.ShowHealth then table.insert(textParts, string.format("%dHP", math.floor(humanoid.Health))) end
                    
                    if #textParts > 0 then
                        local headPos = Camera:WorldToViewportPoint(head.Position)
                        esp.text.Text = table.concat(textParts, " | ")
                        esp.text.Position = Vector2.new(headPos.X, headPos.Y - 25)
                        esp.text.Color = espColor
                        esp.text.Visible = true
                    else
                        esp.text.Visible = false
                    end
                    
                    -- Visibility status
                    if Settings.ESP.ShowVisibility then
                        local headPos = Camera:WorldToViewportPoint(head.Position)
                        esp.statusText.Text = isVisible and "VISIBLE" or "HIDDEN"
                        esp.statusText.Position = Vector2.new(headPos.X, headPos.Y - 10)
                        esp.statusText.Color = espColor
                        esp.statusText.Visible = true
                    else
                        esp.statusText.Visible = false
                    end
                    
                    -- Box ESP
                    if Settings.ESP.ShowBoxes then
                        local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                        local legPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                        
                        local height = math.abs(headPos.Y - legPos.Y)
                        local width = height / 2
                        
                        esp.box.Size = Vector2.new(width, height)
                        esp.box.Position = Vector2.new(hrpPos.X - width/2, headPos.Y)
                        esp.box.Color = espColor
                        esp.box.Visible = true
                    else
                        esp.box.Visible = false
                    end
                    
                    -- Skeleton ESP
                    if Settings.ESP.ShowSkeleton then
                        local skeletonParts = {
                            {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
                            {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"},
                            {"LeftLowerArm", "LeftHand"}, {"UpperTorso", "RightUpperArm"},
                            {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
                            {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"},
                            {"LeftLowerLeg", "LeftFoot"}, {"LowerTorso", "RightUpperLeg"},
                            {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}
                        }
                        
                        for i, parts in ipairs(skeletonParts) do
                            local part1 = character:FindFirstChild(parts[1])
                            local part2 = character:FindFirstChild(parts[2])
                            
                            if part1 and part2 and esp.skeleton[i] then
                                local pos1, onScreen1 = Camera:WorldToViewportPoint(part1.Position)
                                local pos2, onScreen2 = Camera:WorldToViewportPoint(part2.Position)
                                
                                if onScreen1 and onScreen2 then
                                    esp.skeleton[i].From = Vector2.new(pos1.X, pos1.Y)
                                    esp.skeleton[i].To = Vector2.new(pos2.X, pos2.Y)
                                    esp.skeleton[i].Color = espColor
                                    esp.skeleton[i].Visible = true
                                else
                                    esp.skeleton[i].Visible = false
                                end
                            elseif esp.skeleton[i] then
                                esp.skeleton[i].Visible = false
                            end
                        end
                    else
                        for _, line in pairs(esp.skeleton) do line.Visible = false end
                    end
                else
                    esp.text.Visible = false
                    esp.statusText.Visible = false
                    esp.box.Visible = false
                    for _, line in pairs(esp.skeleton) do line.Visible = false end
                end
            else
                esp.text.Visible = false
                esp.statusText.Visible = false
                esp.box.Visible = false
                for _, line in pairs(esp.skeleton) do line.Visible = false end
            end
        else
            esp.text.Visible = false
            esp.statusText.Visible = false
            esp.box.Visible = false
            for _, line in pairs(esp.skeleton) do line.Visible = false end
        end
    end
end)

print("[TR4CE] ESP system loaded with skeleton")
