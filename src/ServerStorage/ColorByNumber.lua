local ColorByNumber = {}

local ColorMap = require(script.Parent.ColorMap)
local Table = require(script.Parent.Table)
local Players = game:GetService("Players")

ColorByNumber.colorMap = {}

function ColorByNumber.getTouchedEvent(model, color, resetAction)
	local playerStorage = require(script.Parent.PlayerStorage)
	local colorByNumber = require(script.Parent.ColorByNumber)
    local PlayerState = require(script.Parent.PlayerState)
	local Workspace = game:GetService("Workspace")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local DingSound = Workspace:WaitForChild("Ding")
	local SimpleChimesSound = Workspace:WaitForChild("SimpleChimes")
	local playSoundEvent = ReplicatedStorage:WaitForChild("PlaySoundEvent")

	local function onMapCompleted(colorMap)
		local players = Table.Select(Table.Distinct(colorMap.PartsAssigned, function(assigned)
			return assigned.Player.UserId
		end), function(playerAssigned)
			return playerAssigned.Player
		end)

		local colors = Table.Distinct(colorMap.PartsAssigned, function(assigned)
			return assigned.Part.BrickColor
		end)
		for _, player in ipairs(players) do
			playSoundEvent:FireClient(player, SimpleChimesSound.SoundId)
		end

		local groupName = colorMap.Name
		delay(5, function()
			local colorMap2 = colorByNumber:getColorMap(groupName)
			for _, player in ipairs(players) do
				local playerAssignments = Table.Where(colorMap2.PartsAssigned, function(assigned)
					return assigned.Player == player
				end)
				local playerStatus = playerStorage.getStatus(player)
				playerStatus.addPoints(#colors * #playerAssignments * #players)
				playSoundEvent:FireClient(player, DingSound.SoundId)
			end

			colorMap2:reset()
		end)
	end

	-- Ensure we don't multi-map the copmleted event for every part
	-- in the map group, call connect once
	local registerColorMap = colorByNumber:getColorMap(model.Parent.Name)
	registerColorMap:ConnectOnce(onMapCompleted)

	return function(touched)
		local localPlayer = PlayerState.IsTouched(touched)
		local localPlayerStatus = playerStorage.getStatus(localPlayer)
		if not localPlayerStatus then
			return
		end

		local playerColor = localPlayerStatus.getColor()
		if not color or playerColor ~= color or color == model.BrickColor then
			return
		end

		local groupName = model.Parent.Name
		local colorMap = colorByNumber:getColorMap(groupName)
		if colorMap.IsCompleted then
			return
		end

		model.BrickColor = color
		localPlayerStatus.addPoints(1)
		colorByNumber:updateColorMap(localPlayer, model, resetAction)
	end
end

function ColorByNumber:getColorMap(groupName)
	if not self.colorMap[groupName] then
		self.colorMap[groupName] = ColorMap.new(groupName)
	end

	return self.colorMap[groupName]
end

function ColorByNumber:updateColorMap(player, part, resetAction)
	if not part.Parent then
		return
	end

	local groupName = part.Parent.Name
	local colorMap = self:getColorMap(groupName)

	-- If the map is already completed, exit
	if colorMap.IsCompleted then
		return
	end

	-- If the part is already assigned, exit
	local partAssigned = Table.Any(colorMap.PartsAssigned, function(assinged)
		return assinged.Part == part
	end)
	if partAssigned then
		return
	end

	-- Add the mapping of this part to the player
	colorMap:addMapping(player, part, resetAction)

	-- If the map has all its parts assigned
	if #colorMap.PartsAssigned >= #part.Parent:GetChildren() then
		colorMap:completed(groupName)
	end
end

function ColorByNumber:reset(groupName)
	local colorMap = self:getColorMap(groupName)
	colorMap:reset()
end

function ColorByNumber:removePlayer(player)
	for _, colorMap in pairs(self.colorMap) do
		colorMap:removePlayer(player)
	end
end

Players.PlayerRemoving:Connect(function(player)
	ColorByNumber:removePlayer(player)
end)

return ColorByNumber
