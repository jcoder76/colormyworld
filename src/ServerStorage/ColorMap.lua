local ColorMap = {}
ColorMap.__index = ColorMap

function ColorMap.new(name)
	local self = setmetatable({}, ColorMap)
	self.Name = name
	self.PartsAssigned = {}
	self.MapCompletedEvent = Instance.new("BindableEvent")
	self.MapCompleted = self.MapCompletedEvent.Event
	self.Connection = nil
	self.IsCompleted = false
	return self
end

function ColorMap:ConnectOnce(handler)
	if self.Connection ~= nil then
		return
	end

	self.Connection = self.MapCompleted:Connect(handler)
end

function ColorMap:Disconnect()
	if self.Connection == nil then
		return
	end

	self.Connection:Disconnect()
end

function ColorMap:addMapping(player, part, resetAction)
	table.insert(
		self.PartsAssigned,
		{
			Player = player,
			Part = part,
			ResetAction = resetAction
		})
end

function ColorMap:completed()
	self.IsCompleted = true
	self.MapCompletedEvent:Fire(self)
end

function ColorMap:reset()
	for _, assigned in ipairs(self.PartsAssigned) do
		if not assigned.ResetAction then
			continue
		end

		assigned.ResetAction(assigned.Part)
	end

	self.PartsAssigned = {}
	self.IsCompleted = false
end

function ColorMap:removePlayer(player)
	for i, map in ipairs(self.PartsAssigned) do
		if map.Player ~= player then
			continue
		end

		table.remove(self.PartsAssigned, i)
		if not map.ResetAction then
			continue
		end

		map.ResetAction(map.Part)
	end
end

return ColorMap
