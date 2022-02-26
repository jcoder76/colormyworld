--!strict
local PrivateRoomGameState = {}
PrivateRoomGameState.__index = PrivateRoomGameState

function PrivateRoomGameState.new(floor: any)
	local self = setmetatable({}, PrivateRoomGameState)
	local privateAvailable: TextLabel
	local privateClaimed: TextLabel
	local resetTimer: TextLabel
	if floor == nil then
		-- Generate blank types for the type inference system
		privateAvailable = Instance.new("TextLabel")
		privateClaimed = Instance.new("TextLabel")
		resetTimer = Instance.new("TextLabel")
	else
		-- Extract the actual text labels
		local surfaceGui = floor.Parent.PrivateRoomBackDisplay.SurfaceGui
		privateClaimed = surfaceGui.PrivateSpaceClaimed
		privateAvailable = surfaceGui.PrivateSpaceAvailable
		resetTimer = surfaceGui.InactivityResetTimer
	end
	self.OwnerName = ""
	self.OwnerUserId = ""
	self.PrivateClaimed = privateClaimed
	self.PrivateAvailable = privateAvailable
    self.ResetTimer = resetTimer
	-- Needed by Timer object to define timer polling interval
	self.Interval = function()
		return 0.5
	end
    return self
end

function PrivateRoomGameState:UpdateTimer(timeLeft: number)
    self.ResetTimer.Text = tostring(timeLeft)
    self.ResetTimer.Visible = true
end

function PrivateRoomGameState:Reset()
    self.OwnerName = ""
    self.OwnerUserId = ""
    self.PrivateClaimed.Visible = false
    self.PrivateAvailable.Visible = true
    self.ResetTimer.Visible = false
end

function PrivateRoomGameState:HasOwner(): boolean
	return self.OwnerUserId and self.OwnerUserId ~= ""
end

function PrivateRoomGameState:IsOwner(player: Player): boolean
	return player and player.UserId and
		(not self:HasOwner() or self.OwnerUserId == tostring(player.UserId))
end

function PrivateRoomGameState:UpdateOwner(player: Player)
	self.OwnerName = player.Name
	self.OwnerUserId = tostring(player.UserId)
	self.PrivateAvailable.Visible = false
	self.PrivateClaimed.Text = "Claimed by " .. player.Name
	self.PrivateClaimed.Visible = true
end

type PrivateRoomGameState = typeof(PrivateRoomGameState.new(nil))

return PrivateRoomGameState