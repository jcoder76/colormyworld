--!strict
local ColorMeRedBlueController = {}
ColorMeRedBlueController.__index = ColorMeRedBlueController

-- Default Color Plum
ColorMeRedBlueController.DefaultColor = BrickColor.new(127, 47, 123)

function ColorMeRedBlueController.new(model: any, table: any)
    local self = setmetatable({}, ColorMeRedBlueController)
    self.Table = table
    self.Model = model
    return self
end

function ColorMeRedBlueController:Reset()
    for _, childModel in pairs(self.Model:GetDescendants()) do
        self:ResetTile(childModel)
    end
end

function ColorMeRedBlueController:ResetTile(tile: any)
	if not tile.Name or tile.Name ~= "ColorMeRedBlue" then
		return
	end
    tile.BrickColor = ColorMeRedBlueController.DefaultColor
    self:UpdateScore()
end

function ColorMeRedBlueController:SetTile(tile: any, player: any)
    local playerStatus = self.PlayerStorage.getStatus(player)
    if not playerStatus then
        return
    end
    tile.BrickXColor = playerStatus.getTeamColor()
    self:UpdateScore()
end

function ColorMeRedBlueController:UpdateScore()
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
        return tile.BrickColor == ColorMeRedBlueController.DefaultColor
    end)
    total = redCount + blueCount + unsetCount
    self.Model.BlueScore.SurfaceGui.BlueArea = blueCount / total * 100
    self.Model.RedScore.SurfaceGui.RedArea = redCount / total * 100
end

return ColorMeRedBlueController