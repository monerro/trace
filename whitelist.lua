--// WHITELIST SYSTEM
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

local WHITELIST = {
    ["iswagtothemax"] = true,
    ["e_ufa"] = true,
    ["y_uex"] = true
}

local WEBHOOK_URL = "https://discord.com/api/webhooks/1457282246493868064/OqM69X93QeYv4edCRps5KFzuqPAMTu73foJRmH7FLgE06nUVRZYaARXEbVvgylXJmmbB"

local function sendWebhook(title, description, color)
    local data = {
        ["embeds"] = {{
            ["title"] = title,
            ["description"] = description,
            ["color"] = color,
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%S")
        }}
    }
    
    local success, response = pcall(function()
        return request({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(data)
        })
    end)
    
    return success
end

-- Whitelist check
if not WHITELIST[LocalPlayer.Name] then
    sendWebhook(
        "❌ Unauthorized Access Attempt",
        "**User:** " .. LocalPlayer.Name .. "\n**UserID:** " .. LocalPlayer.UserId .. "\n**Game:** " .. game.PlaceId,
        15158332
    )
    LocalPlayer:Kick("not whitelisted! https://discord.gg/45PFwjTVpe")
    return
end

sendWebhook(
    "✅ Authorized Login",
    "**User:** " .. LocalPlayer.Name .. "\n**UserID:** " .. LocalPlayer.UserId .. "\n**Game:** " .. game.PlaceId,
    3066993
)

-- Export if needed by other modules
return {
    sendWebhook = sendWebhook,
    WHITELIST = WHITELIST
}
