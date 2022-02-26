--!strict
local ColorMe = {}
ColorMe.__index = ColorMe

function ColorMe.getColorMeTouchedEvent(model: any)
    local PlayerState = require(script.Parent.PlayerState)
    local playerStorage = require(script.Parent.PlayerStorage)

	return function(touched: any)
		local playerStatus = playerStorage.getStatus(PlayerState.IsTouched(touched))
		if not playerStatus or not playerStatus.getPaintEnabled() then
			return
		end

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

function ColorMe.getColorChangeTouchedEvent(model: any)
    local PlayerState = require(script.Parent.PlayerState)
    local playerStorage = require(script.Parent.PlayerStorage)

	return function(touched: any)
		local localPlayerStatus = playerStorage.getStatus(PlayerState.IsTouched(touched))
		if not localPlayerStatus then
			return
		end

		local playerColor = localPlayerStatus.getColor()

		if not model.BrickColor or playerColor == model.BrickColor then
			return
		end

		localPlayerStatus.setColor(model.BrickColor)
	end
end

function ColorMe.getMaterialChangeTouchedEvent(model: any, points: number)
    local PlayerState = require(script.Parent.PlayerState)
    local playerStorage = require(script.Parent.PlayerStorage)

	return function(touched: any)
		local localPlayerStatus = playerStorage.getStatus(PlayerState.IsTouched(touched))
		if not localPlayerStatus then
			return
		end

		local playerColor = localPlayerStatus.getColor()

		if not model.BrickColor or playerColor == model.BrickColor then
			return
		end

		localPlayerStatus.setMaterial(model.Material)
		localPlayerStatus.setTransparency(model.Transparency)
		localPlayerStatus.setPointsEarned(points)
	end
end

return ColorMe