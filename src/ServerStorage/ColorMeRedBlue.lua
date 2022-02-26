--!strict
local ColorMeRedBlue = {}
ColorMeRedBlue.__index = ColorMeRedBlue

-- Default Color Plum
ColorMeRedBlue.DefaultColor = BrickColor.new(127, 47, 123)

function ColorMeRedBlue.new(model: any, playerStorage: any, gameLength: number, preStart: number,
                            table: any, controllerFactory: (any)->any, timerFactory: (any)->any, timedGameFactory: (any)->any)
    local self = setmetatable({}, ColorMeRedBlue)
    self.PlayerStorage = playerStorage
    self.Table = table
    self.Controller = controllerFactory(model, table)
    local context = {
        Interval = function()
            return 0.5
        end,
        Controller = self.Controller,
    }
    self.TimedGame = timedGameFactory(context, gameLength, preStart, timerFactory)
    self.TimedGame.TimerUpdated:Connect(function(_context, _, time)
        local surfaceGui = _context.Controller.Model.RedBlueTimer.SurfaceGui
        local timerDisplay = surfaceGui.RedBlueTime
        timerDisplay.Text = tostring(time)
    end)
    self.TimedGame.GameStarted:Connect(function(_self)
        local _context = _self.Context
        context:Reset()
        context:StopCounter()
        context:TramsportPlayers()
        self:Start()
    end)
    self.TimedGame.GameEnded:Connect(function(_self)
        self:ScoreGame()
    end)
    return self
end

function ColorMeRedBlue.getTouchedEvent(model: any)
    local playerStorage = require(script.Parent.PlayerStorage)
    local PlayerState = require(script.Parent.PlayerState)

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

function ColorMeRedBlue:Reset()
    for _, childModel in pairs(self.Model:GetDescendants()) do
        self:ResetTile(childModel)
    end
end

function ColorMeRedBlue:Start()
    self.TimedGame:StartCounter()
end

function ColorMeRedBlue:ResetTile(tile: any)
	if not tile.Name or tile.Name ~= "ColorMeRedBlue" then
		return
	end
    tile.BrickColor = ColorMeRedBlue.DefaultColor
    self:UpdateScore()
end

function ColorMeRedBlue:SetTile(tile: any, player: any)
    local playerStatus = self.PlayerStorage.getStatus(player)
    if not playerStatus then
        return
    end
    tile.BrickXColor = playerStatus.getTeamColor()
    self:UpdateScore()
end

function ColorMeRedBlue:UpdateScore()
    local total: number
    local redCount: number
    local blueCount: number
    local unsetCount: number
    redCount = self.Table.Count(self.Model:GetDecendents(), function(tile)
        return tile.BrickColor == BrickColor.Red
    end)
    blueCount = self.Table.Count(self.Model:GetDecendents(), function(tile)
        return tile.BrickColor == BrickColor.Blue
    end)
    unsetCount = self.Table.Count(self.Model:GetDecendents(), function(tile)
        return tile.BrickColor == ColorMeRedBlue.DefaultColor
    end)
    total = redCount + blueCount + unsetCount
    self.Model.BlueScore.SurfaceGui.BlueArea = blueCount / total * 100
    self.Model.RedScore.SurfaceGui.RedArea = redCount / total * 100
end

return ColorMeRedBlue