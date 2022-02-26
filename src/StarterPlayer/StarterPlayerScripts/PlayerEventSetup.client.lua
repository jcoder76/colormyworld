local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local camera = workspace.CurrentCamera
local player = Players.LocalPlayer
local cameraChangedEvent = ReplicatedStorage:WaitForChild("CameraChangedEvent")
local playSoundEvent = ReplicatedStorage:WaitForChild("PlaySoundEvent")

cameraChangedEvent.OnClientEvent:Connect(function(cameraAngle, zoomDistance)
	local cameraOffset = Vector3.new(2, 2, zoomDistance)
	local cameraAngleY = -10
	local cameraAngleX = cameraAngle

	local primaryPart = player.Character.PrimaryPart
	local originalCameraType = camera.CameraType
	camera.CameraType = Enum.CameraType.Scriptable

	local startCFrame = CFrame.new((primaryPart.CFrame.Position)) * CFrame.Angles(0, math.rad(cameraAngleX), 0) * CFrame.Angles(math.rad(cameraAngleY), 0, 0)
	local cameraCFrame = startCFrame:ToWorldSpace(CFrame.new(cameraOffset.X, cameraOffset.Y, cameraOffset.Z))
	local cameraFocus = startCFrame:ToWorldSpace(CFrame.new(cameraOffset.X, cameraOffset.Y, -10000))
	camera.CFrame = CFrame.new(cameraCFrame.Position, cameraFocus.Position)
	camera.CameraType = originalCameraType
end)

local function playLocalSound(soundId)
	-- Create a sound
	local sound = Instance.new("Sound")
	sound.SoundId = soundId

	-- Play the sound locally
	SoundService:PlayLocalSound(sound)

	-- Once the sound has finished, destroy it
	-- Commented out because it doesn't seem to trigger the Ended event
	--sound.Ended:Wait()
	sound:Destroy()
end

playSoundEvent.OnClientEvent:Connect(function(...)
	for _, soundId in ipairs({...}) do
		playLocalSound(soundId)
	end
end)
