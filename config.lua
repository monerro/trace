--// CONFIGURATION
local Settings = {
    Aimbot = {
        Enabled = false,
        HoldMode = true,
        HoldKey = Enum.KeyCode.E,
        Smoothness = 0.15,
        BodyPart = "Head",
        TeamCheck = true,
        WallCheck = false,
        CustomTeams = false,
        TargetTeams = {
            ["class-d"] = true,
            ["chaos"] = true,
            ["security"] = false,
            ["scientific"] = false,
            ["medical"] = false
        }
    },
    FOV = {
        Enabled = true,
        DrawCircle = true,
        Radius = 150
    },
    ESP = {
        Enabled = false,
        TeamCheck = true,
        ShowBoxes = true,
        ShowNames = true,
        ShowHealth = true,
        ClassDColor = Color3.fromRGB(255,140,0),
        SecurityColor = Color3.fromRGB(0,100,255)
    },
    Damage = {
        Enabled = false,
        HitSound = false
    },
    Misc = {
        HideCharacter = false,
        Noclip = false,
        NoclipKey = Enum.KeyCode.N,
        InfiniteJump = false,
        Fullbright = false
    }
}

-- Store globally
_G.Settings = Settings
print("[TR4CE] Config loaded")
return Settings
