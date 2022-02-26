spawn(function()
	local ServerStorage = game:GetService("ServerStorage")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local playerStorage = require(ServerStorage:WaitForChild("PlayerStorage"))
	local setPaintStateEvent = ReplicatedStorage:WaitForChild("SetPaintStateEvent")

	setPaintStateEvent.OnServerEvent:Connect(function(player, enabled)
		local status = playerStorage.getStatus(player)
		if not status then
			return
		end

		status.setPaintEnabled(enabled)
	end)
end)
