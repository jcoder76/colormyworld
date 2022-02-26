local PlayerStorage = {}
PlayerStorage.Status = {}

local AUTOSAVE_INTERVAL = 120

local highScores = require(script.Parent.HighScores)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local pointsChangedEvent = ReplicatedStorage:WaitForChild("PointsChangedEvent")
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local playerData = DataStoreService:GetDataStore("PlayerData")
local RunService = game:GetService("RunService")
local testMode = RunService:IsStudio()

function PlayerStorage.getStatus(player)
	if not player then
		return nil
	end
	if not PlayerStorage.Status[player.UserId] then
		PlayerStorage.Status[player.UserId] = {}
	end

	local status = PlayerStorage.Status[player.UserId]

	if not status.playerColor then
		status.playerColor = BrickColor.Gray()
	end

	if not status.teamColor then
		status.teamColor = BrickColor.Gray()
	end

	if status.playerPaintEnabled == nil then
		status.playerPaintEnabled = true
	end

	if status.Loaded == nil then
		status.Loaded = false
	end

	if not status.PointsChangedEvent then
		local newEvent = Instance.new("BindableEvent")
		status.PointsChangedEvent = newEvent
		status.PointsChanged = newEvent.Event
	end

	local function onPointsChanged(points)
		status.PointsChangedEvent:Fire(player, points)
		pointsChangedEvent:FireClient(player, points)
	end

	function status.getColor()
		return status["playerColor"]
	end

	function status.setColor(color)
		status["playerColor"] = color
	end

	function status.getTeamColor()
		return status["teamColor"]
	end

	function status.setTeamColor(color)
		status["teamColor"] = color
	end

	function status.getMaterial()
		return status["playerMaterial"]
	end

	function status.setMaterial(material)
		status["playerMaterial"] = material
	end

	function status.getTransparency()
		local transparency = status["playerTransparency"]
		if not transparency then
			return 0
		end

		return transparency
	end

	function status.setTransparency(transparency)
		status["playerTransparency"] = transparency
	end

	function status.getPaintEnabled()
		return status["playerPaintEnabled"]
	end

	function status.setPaintEnabled(enabled)
		status["playerPaintEnabled"] = enabled
	end

	function status.getPoints()
		local points = status["playerPoints"]
		if not points then
			return 0
		end

		return points
	end

	function status.setPoints(points)
		status["playerPoints"] = points
		onPointsChanged(status["playerPoints"])
		highScores:updateScore(player, points)
	end

	function status.getPointsEarned()
		local pointsEarned = status["playerPointsEarned"]
		if not pointsEarned then
			if testMode then
				return 1000
			end
			return 1
		end

		return pointsEarned
	end

	function status.setPointsEarned(pointsEarned)
		status["playerPointsEarned"] = pointsEarned
	end

	function status.addPoints(points)
		status.setPoints(status.getPoints() + points)
	end

	return status
end

local function saveStatus(player)
	local status = PlayerStorage.getStatus(player)
	-- Don't overwrite score if user data didn't load
	if not status.Loaded then
		return
	end

	local points = status.getPoints()
	local success, err = pcall(function()
		playerData:UpdateAsync(player.UserId, function(currentValue)
			if not currentValue then
				currentValue = {}
				currentValue.playerPoints = 0
			end

			if currentValue.playerPoints > points then
				status.setPoints(currentValue.playerPoints)
				return currentValue
			end

			currentValue.playerPoints = points
			return currentValue
		end)
	end)
	if not success then
		warn("Failed to save player data, retrying in " .. AUTOSAVE_INTERVAL .. " seconds: " .. err)
		return
	end
end

local function loadStatus(player)
	local status = PlayerStorage.getStatus(player)
	local success, data = pcall(function()
		return playerData:GetAsync(player.UserId)
	end)

	status.Loaded = success
	if not success then
		warn("Failed loading player data, will retry in " .. AUTOSAVE_INTERVAL .. " seconds.")
		delay(AUTOSAVE_INTERVAL, function()
			loadStatus(player)
		end)

		return
	end

	if not data or not data.playerPoints or data.playerPoints < status.getPoints() then
		return
	end
	status.setPoints(data.playerPoints)
end

local function autoSave()
	for _, player in pairs(Players:GetChildren()) do
		saveStatus(player)
	end

	delay(AUTOSAVE_INTERVAL, autoSave)
end

delay(AUTOSAVE_INTERVAL, autoSave)

Players.PlayerAdded:connect(loadStatus)
Players.PlayerRemoving:connect(saveStatus)

return PlayerStorage