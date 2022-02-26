local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local screenGui = script.Parent
local pointsUi = screenGui.PlayerStatus.Points
local pointsBlackUi = screenGui.PlayerStatus.PointsBlack
local playerNameUi = screenGui.PlayerStatus.PlayerName
local playerNameBlackUi = screenGui.PlayerStatus.PlayerNameBlack

playerNameUi.Text = localPlayer.Name
playerNameBlackUi.Text = localPlayer.Name

local pointsChangedEvent = ReplicatedStorage:WaitForChild("PointsChangedEvent")
pointsChangedEvent.OnClientEvent:Connect(function(points)
	local pointsStr = string.format("%08d", points)
	pointsUi.Text = pointsStr
	pointsBlackUi.Text = pointsStr
end)
