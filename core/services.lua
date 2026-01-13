local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")

return {
    Players = Players,
    RunService = RunService,
    UserInputService = UserInputService,
    TweenService = TweenService,
    HttpService = HttpService,
    Lighting = Lighting,
    Camera = workspace.CurrentCamera,
    LocalPlayer = Players.LocalPlayer
}

