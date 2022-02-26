-- PrivateRoomGameState
--!strict
local PrivateRoom = {}
PrivateRoom.__index = PrivateRoom

local PlayerState = require(script.Parent.PlayerState)
local Table = require(script.Parent.Table)
local TimedGame = require(script.Parent.TimedGame)
local PrivateRoomGameState = require(script.Parent.PrivateRoomGameState)

local instanceTable = {}

local function getInstance(source: any): any
	local result = Table.FirstOrDefault(instanceTable, function(entry: any)
		return source and entry and entry.Source == source
	end)
	if not result then
		return nil
	end

	return result.Value
end

local function setInstance(source: any, value: any)
	if getInstance(source) == value then
		return
	end
	local result = Table.FirstOrDefault(instanceTable, function(entry: any)
		return source ~= nil and entry.Source == source
	end)

	if result then
		result.Value = value
		return
	end

	table.insert(instanceTable, {
		Source = source,
		Value = value,
	})
end

function PrivateRoom.getTouchedEvent(model)
    local playerStorage = require(script.Parent.PlayerStorage)

	return function(touched)
		print("touched event received")
		local player = PlayerState.IsTouched(touched)
		local playerStatus = playerStorage.getStatus(player)
		if not model or not model.Parent or not playerStatus or not playerStatus.getPaintEnabled() then
			return
		end

		local privateRoom = PrivateRoom.getPrivateRoom(model.Parent)
		if not privateRoom or not privateRoom:IsOwner(player) then
			return
		end

		privateRoom:UpdateOwner(player)
		local tileChanged = false
		local color = playerStatus.getColor()
		if color and color ~= model.BrickColor then
			model.BrickColor = color
			tileChanged = true
		end

		local material = playerStatus.getMaterial()
		if material and material ~= model.Material then
			model.Material = material
			tileChanged = true
		end

		local transparency = playerStatus.getTransparency()
		if transparency and transparency ~= model.Transparency then
			model.Transparency = transparency
			tileChanged = true
		end

		if not tileChanged then
			return
		end

		playerStatus.addPoints(playerStatus.getPointsEarned())
	end
end

function PrivateRoom.getPrivateRoom(floor: any)
	local self: any
	if floor ~= nil then
		-- Get an exising instance if possible
		self = getInstance(floor)
		if self then
			return self
		end
	end

	self = setmetatable({}, PrivateRoom)
	self.GameState = PrivateRoomGameState.new(floor)
	self.TouchedTimer = TimedGame.new(self.GameState, 200)
	self.TouchedTimer.TimerUpdated:Connect(function(_, _, timer)
		if not self:HasOwner() then
			return
		end

		self:UpdateTimer(timer)
	end)
	self.TouchedTimer.GameEnded:Connect(function()
		if not self:HasOwner() then
			return
		end

		self:Reset()
	end)

	if floor ~= nil then
		setInstance(floor, self)
	end
	return self
end

function PrivateRoom:Reset()
	self.TouchedTimer:StopCounter()
	self.GameState:Reset()
end

function PrivateRoom:HasOwner(): boolean
	return self.GameState and self.GameState:HasOwner()
end

function PrivateRoom:IsOwner(player): boolean
	return self.GameState and self.GameState:IsOwner(player)
end

function PrivateRoom:UpdateTimer(timeLeft: number)
	if not self.GameState then
		return
	end

	self.GameState:UpdateTimer(timeLeft)
end

function PrivateRoom:UpdateOwner(player)
	local otherRooms = Table.Where(Table.Select(instanceTable, function(map)
		return map.Value
	end), function(room)
		return room and room ~= self and room:IsOwner(player)
	end)
	for _, otherRoom in ipairs(otherRooms) do
		otherRoom:Reset()
	end

	self.GameState:UpdateOwner(player)
	self.TouchedTimer:ResetCounter()
	self.TouchedTimer:StartCounter()
end

type PrivateRoom = typeof(PrivateRoom.getPrivateRoom(nil))

return PrivateRoom
