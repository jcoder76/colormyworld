local ReturnPad = {}
ReturnPad.__index = ReturnPad

function ReturnPad.getTouchedEvent(returnPoint)
    local PlayerState = require(script.Parent.PlayerState)
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local cameraChangedEvent = ReplicatedStorage:WaitForChild("CameraChangedEvent")

    return function(touched)
		local player = PlayerState.IsTouched(touched)
		if not player then
			return
		end

		local faceAngle = 90

		-- Get the CFrane set up to teleport on top of the ReturnPoint facing towards the spawn point
		local offset = Vector3.new(0,returnPoint.Size.Y/2 + player.Character.PrimaryPart.Size.Y/2,0)
		local returnPosition = CFrame.new(returnPoint.Position + offset) * CFrame.Angles(0, math.rad(faceAngle), 0)
		player:RequestStreamAroundAsync(returnPosition.Position)
		cameraChangedEvent:FireClient(player, faceAngle, 2)
		player.Character:SetPrimaryPartCFrame(returnPosition)
	end
end

return ReturnPad