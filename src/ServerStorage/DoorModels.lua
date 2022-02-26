local DoorModels = {}

local playerStorage = require(script.Parent.PlayerStorage)
local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")

local function getPlayerTouched(touched)
	if not touched.Parent:IsA("Model") or not touched.Parent:FindFirstChild("Humanoid") then
		return nil
	end

	return Players:GetPlayerFromCharacter(touched.Parent)
end

function DoorModels.getDoorTouchedEvent(door, doorModel)
	if door and doorModel and doorModel.SetupDoor then
		doorModel:SetupDoor(door)
	end

	return function(touched)
		local player = getPlayerTouched(touched)
		local localPlayerStatus = playerStorage.getStatus(player)
		if not doorModel or not localPlayerStatus then
			return
		end

		doorModel:OpenDoor(player, localPlayerStatus)
	end
end

-- Door Models here

local function createCollisionGroup(name)
	if not name then
		return false
	end
	local success, groupId = pcall(PhysicsService.GetCollisionGroupId, PhysicsService, name)

	if success and groupId then
		return true
	end

	PhysicsService:CreateCollisionGroup(name)
end

local function setPlayerCollisionGroup(player, name)
	for _, child in ipairs(player.Character:GetChildren()) do
		if child:IsA("BasePart") then
			if PhysicsService:CollisionGroupContainsPart(name, child) then
				break
			end
			PhysicsService:SetPartCollisionGroup(child, name)
		end
	end
end

function DoorModels.HasPoints(points)
	local DoorModel = {}

	DoorModel.DoorCollisionGroup = "DoorMinimumPoints" .. points
	DoorModel.PlayerCollisionGroup = "PlayerMinimumPoints" .. points
	createCollisionGroup(DoorModel.DoorCollisionGroup)
	createCollisionGroup(DoorModel.PlayerCollisionGroup)
	PhysicsService:CollisionGroupSetCollidable(DoorModel.DoorCollisionGroup, DoorModel.PlayerCollisionGroup, false)

	function DoorModel.CanEnter(status)
		return status.getPoints() >= points
	end

	function DoorModel:SetupDoor(door)
		if not self.DoorCollisionGroup then
			return
		end

		PhysicsService:SetPartCollisionGroup(door, self.DoorCollisionGroup)
	end

	function DoorModel:OpenDoor(player, status)
		-- Verify the plauer meets the model contraints
		if not self.CanEnter(status) then
			return
		end

		setPlayerCollisionGroup(player, self.PlayerCollisionGroup)
	end

	return DoorModel
end

return DoorModels
