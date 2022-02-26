local EasterHuntApp = {}
EasterHuntApp.__index = EasterHuntApp

function EasterHuntApp.Run(container: table)
	local ColorMe = require(script.Parent.ColorMe)
	local ReturnPad = require(script.Parent.ReturnPad)
	local highScores = require(script.Parent.HighScores)
	local doorModels = require(script.Parent.DoorModels)
	local Workspace = game.Workspace
    local ReturnPoint = Workspace:WaitForChild("ReturnPoint")
	local WelcomeSign = Workspace:WaitForChild("WelcomeSign")
	local HighScoreBoard = WelcomeSign:WaitForChild("HighScoreBoard")
	local PlacesText = HighScoreBoard:WaitForChild("Places")
	local UserNamesText = HighScoreBoard:WaitForChild("UserNames")
	local HighScoresText = HighScoreBoard:WaitForChild("HighScores")
	local workspaceList = Workspace:GetDescendants()

	highScores.ScoresChanged:Connect(function(highScoresList)
		local placesStr = ""
		local userNamesStr = ""
		local highScoresStr = ""
		for i, score in ipairs(highScoresList) do
			placesStr = placesStr .. i .. "\n"
			userNamesStr = userNamesStr .. score.Name .. "\n"
			highScoresStr = highScoresStr .. string.format("%08d", score.Score) .. "\n"
		end

		PlacesText.Text = placesStr
		UserNamesText.Text = userNamesStr
		HighScoresText.Text = highScoresStr
	end)

	local function setupMaterialChange(part)
		local config = part:FindFirstChild("Configuration")
		local pointMultiplier = config:FindFirstChild("PointMultiplier")
		local pointMul = pointMultiplier.Value
		part.Touched:Connect(ColorMe.getMaterialChangeTouchedEvent(part, pointMul))
	end

	local function setupDoor(door)
		local entrance1 = door:WaitForChild("Entrance1")
		local entrance2 = door:WaitForChild("Entrance2")
		local config = door:FindFirstChild("Configuration")
		local minPoints = config:FindFirstChild("MinimumPoints")
		local minimumPoints = minPoints.Value

		-- Defines the door model to use for each entrance
		entrance1.Touched:Connect(doorModels.getDoorTouchedEvent(door, doorModels.HasPoints(minimumPoints)))
		entrance2.Touched:Connect(doorModels.getDoorTouchedEvent(door, doorModels.HasPoints(minimumPoints)))
	end

	local partEventActions = {
		ColorMe = function(part)
			part.Touched:Connect(ColorMe.getColorMeTouchedEvent(part))
		end,
		ColorChange = function(part)
			part.Touched:Connect(ColorMe.getColorChangeTouchedEvent(part))
		end,
		ReturnPad = function(part)
			part.Touched:Connect(ReturnPad.getTouchedEvent(ReturnPoint))
		end,
		MatChangeX2ICE = setupMaterialChange,
		Doorway = setupDoor,
	}

	for _, child in pairs(workspaceList) do
		local eventAction
		if child:IsA("BasePart") then
			eventAction = partEventActions[child.Name]
		end
		if not eventAction then
			continue
		end

		local instance = eventAction(child)
		if instance == nil then
			continue
		end

		-- Register all long-lived instances in the top-level container
		table.insert(container, instance)
	end
end

return EasterHuntApp