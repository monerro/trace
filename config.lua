--// CONFIGURATION SETTINGS
local Settings = {
    Aim = {
        Enabled = false,
        HoldMode = true,
        HoldKey = Enum.KeyCode.E,
        Smoothness = 0.15,
        BodyPart = "Head",
        TeamCheck = true,
        WallCheck = false,
        StickyAim = false,
        ADSOnly = true,
        
    FOV = {
        Enabled = true,
        DrawCircle = true,
        Radius = 150,
        Scale = 1
    },
    ESP = {
        Enabled = false,
        TeamCheck = true,
        ShowBoxes = true,
        ShowSkeleton = false,
        ShowNames = true,
        ShowDistance = true,
        ShowHealth = true,
        ShowVisibility = true,
        ShowTeam = true,
        Color = Color3.fromRGB(255,80,10),
        VisibleColor = Color3.fromRGB(0,255,0),
        HiddenColor = Color3.fromRGB(255,50,50),
        ClassDColor = Color3.fromRGB(255,140,0),
        SecurityColor = Color3.fromRGB(0,100,255),
        Size = 13,
        BoxThickness = 1,
        SkeletonThickness = 1,
        Chams = false,
        ChamsTransparency = 0.5
    },
    Damage = {
        Enabled = false,
        ShowCritical = true,
        CriticalThreshold = 50,
        Duration = 2,
        FloatHeight = 3,
        TextSize = 24,
        CriticalSize = 32,
        NormalColor = Color3.fromRGB(255, 255, 255),
        CriticalColor = Color3.fromRGB(255, 50, 50),
        OutlineColor = Color3.fromRGB(0, 0, 0),
        OffsetX = 50,
        OffsetY = 0,
        HitSound = false,
        HitSoundType = "Skeet",
        HitSoundVolume = 0.5
    },
    Misc = {
        HideCharacter = false,
        Noclip = false,
        NoclipKey = Enum.KeyCode.N,
        InfiniteJump = false,
        JumpPower = 50
    },
    PositionHider = {
        Enabled = false,
        ToggleKey = Enum.KeyCode.H,
        ShowClone = true,
        CloneColor = Color3.fromRGB(255, 50, 50)
    }
}

-- Make settings global for other modules
_G.Settings = Settings

print("[TR4CE] Configuration loaded")
