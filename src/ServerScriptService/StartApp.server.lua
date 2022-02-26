--!strict
local container = {}

spawn(function()
	local ServerStorage = game:GetService("ServerStorage")
	local Container = require(ServerStorage:WaitForChild("Container"))
	container = Container.new()
	local localContainer = Container.new()
	localContainer:Register("ServerStorage.Configuration.ModelName", {}, Container.SingletonLifetime
	):Register("App", {"ModelName"}, Container.SingletonLifetime, function(modelName)
		return require(localContainer:Resolve("ServerStorage"):WaitForChild(modelName.Value .. "App"))
	end
	)
	local App = localContainer:Resolve("App")
	App.Run(container)
end)