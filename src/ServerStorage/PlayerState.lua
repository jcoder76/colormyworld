--!strict
local PlayerState = {}
PlayerState.__index = PlayerState

local Players = game:GetService("Players")

function PlayerState.IsTouched(touched: any): boolean
	if not touched or not touched.Parent:IsA("Model") or not touched.Parent:FindFirstChild("Humanoid") then
		return nil
	end

	return Players:GetPlayerFromCharacter(touched.Parent)
end

return PlayerState
