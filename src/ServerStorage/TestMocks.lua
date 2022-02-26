local TestMocks = {}

function TestMocks.getPlayerMock(): table
	return {
		UserId = "TestId1",
		Name = "TestPlayer",
		Character = {
			Humamoid = Instance.new("Humanoid"),
		},
	}
end

-- Creates a basic mock of a color by number group
function TestMocks.getColorByNumberMock(groupName: string): Model
	local group = Instance.new("Model")
	group.Name = groupName
	local part1 = Instance.new("Part")
	part1.Name = "TestPart1"
	part1.Parent = group
	local part2 = Instance.new("Part")
	part2.Name = "TestPart2"
	part2.Parent = group
	return group
end

-- Creates a basic mock of a color me red blue game model
function TestMocks.getColorMeRedBlueMock(): Model
	local group = Instance.new("Model")
	group.Name = "ColorMeRedBlueModel"
	local floor1 = Instance.new("Part")
	floor1.Name = "ColorMeRedBlue"
	floor1.Parent = group
	local floor2 = Instance.new("Part")
	floor2.Name = "ColorMeRedBlue"
	local blueScoreWall = Instance.new("Part")
	blueScoreWall.Name = "BlueScore"
	blueScoreWall.Parent = group
	local redScoreWall = Instance.new("Part")
	redScoreWall.Name = "RedScore"
	redScoreWall.Parent = group
	local blueScoreGui = Instance.new("SurfaceGui")
	blueScoreGui.Name = "ColorMeRedBlueWall"
	blueScoreGui.Parent = blueScoreWall
	local redScoreGui = Instance.new("SurfaceGui")
	redScoreGui.Name = "ColorMeRedBlueWall"
	redScoreGui.Parent = redScoreWall
	return group
end

return TestMocks