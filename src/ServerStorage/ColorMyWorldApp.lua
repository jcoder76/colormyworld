--!strict
local ColorMyWorldApp = {}
ColorMyWorldApp.__index = ColorMyWorldApp

local Container = require(script.Parent.Container)
type Container = typeof(Container.new())

-- Starts the ColorMyWorld application
function ColorMyWorldApp.Run(container: Container)

	-- Register common objects
	container:Register("Table", {}, Container.SingletonLifetime
	):Register("PlayerStorage", {}, Container.SingletonLifetime
	):Register("ColorMe", {}, Container.SingletonLifetime
	):Register("HighScores", {}, Container.SingletonLifetime
	):Register("DoorModels", {}, Container.SingletonLifetime
	):Register("ReturnPad", {}, Container.SingletonLifetime
	):Register("PrivateRoom", {}, Container.SingletonLifetime
	):Register("ColorByNumber", {}, Container.SingletonLifetime
	):Register("TimedGame", {}
	):Register("OfficeDoor", {"OfficeDoorModel"}
	):Register("Sink", {"SinkModel"}
	):Register("Timer", {"context"}
	):Register("Animation", {}
	):Register("FishAnimationFactory", {"->Animation"}, Container.SingletonLifetime, function(animationFactory)
		return function(part)
			animationFactory(
			{
				{
					Action = function(model)
						model.BodyVelocity.Velocity = Vector3.new(2, 0.15, 0)
					end,
					Delay = 2,
				},
				{
					Action = function(model)
						model.BodyVelocity.Velocity = Vector3.new(0, 0.15, 2)
					end,
					Delay = 2,
				},
				{
					Action = function(model)
						model.BodyVelocity.Velocity = Vector3.new(-2, 0.15, 0)
					end,
					Delay = 2,
				},
				{
					Action = function(model)
						model.BodyVelocity.Velocity = Vector3.new(0, 0.15, -2)
					end,
					Delay = 2,
				},
			},
			part)
		end
	end
	):Register("AnimationSystem", {"FishAnimation", "->Timer"}, Container.SingletonLifetime
	):Register("ColorMeRedBlueGameDuration", {}, Container.InstanceLifetime, function()
		return 90
	end
	):Register("ColorMeRedBluePrestartDuration", {}, Container.InstanceLifetime, function()
		return 30
	end
	):Register("ColorMeRedBlue", {"ColorMeRedBlueModel", "PlayerStorage", "ColorMeRedBlueGameDuration", "ColorMeRedBluePrestartDuration", "Table", "->ColorMeRedBlueControllerController", "->Timer", "->TimedGame"}
	):RegisterWorkspace("ReturnPoint", {}, Container.SingletonLifetime
	):RegisterWorkspace("WelcomeSign.HighScoreBoard", {}, Container.SingletonLifetime
	):Register("HighScoreBoard.Places:PlacesModel", {}, Container.SingletonLifetime
	):Register("HighScoreBoard.UserNames:UserNamesModel", {}, Container.SingletonLifetime
	):Register("HighScoreBoard.HighScores:HighScoresModel", {}, Container.SingletonLifetime
	):Register("WorkspaceList", {}, Container.SingletonLifetime, function()
		return container:Resolve("Workspace"):GetDescendants()
	end
	):Register("WorkspaceMapping",
		{"Table", "PlayerStorage", "WorkspaceList",
		"ColorMe", "HighScores", "DoorModels", "ReturnPad", "PrivateRoom", "ColorByNumber",
		"->AnimationSystem", "FishAnimationFactory", "ReturnPoint", "PlacesModel", "UserNamesModel",
		"HighScoresModel", "->OfficeDoor", "->Sink", "->Timer", "->ColorMeRedBlue", "->TimedGame"},
		Container.SingletonLifetime,
		function(tableHelper, playerStorage, workspaceList,
				colorMe, highScores, doorModels, returnPad, privateRoom, colorByNumber,
				animationSystemFactory, fishAnimationFactory, returnPoint, placesModel, userNamesModel,
				highScoresModel, officeDoorFactory, SinkFactory, timerFactory, colorMeRedBlueFactory, timedGameFactory)

			-- Hook up the highscores board to receive score changed event
			highScores.ScoresChanged:Connect(function(highScoresList)
				local placesStr = ""
				local userNamesStr = ""
				local highScoresStr = ""
				for i, score in ipairs(highScoresList) do
					placesStr = placesStr .. i .. "\n"
					userNamesStr = userNamesStr .. score.Name .. "\n"
					highScoresStr = highScoresStr .. string.format("%08d", score.Score) .. "\n"
				end

				placesModel.Text = placesStr
				userNamesModel.Text = userNamesStr
				highScoresModel.Text = highScoresStr
			end)

			local DEFAULT_COLOR = BrickColor.new("Sage green")

			local function setupMaterialChange(part)
				local config = part:FindFirstChild("Configuration")
				local pointMultiplier = config:FindFirstChild("PointMultiplier")
				local pointMul = pointMultiplier.Value
				part.Touched:Connect(colorMe.getMaterialChangeTouchedEvent(part, pointMul))
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

			local function resetPartColor(part)
				part.BrickColor = DEFAULT_COLOR
			end

			local function setupColorByNumber(part)
				local color = part.BrickColor
				resetPartColor(part)
				part.Touched:Connect(colorByNumber.getTouchedEvent(part, color, resetPartColor))
			end

			local function setupFish(part)
				local fishAnimation = fishAnimationFactory(part)
				local fishAnimationSystem = animationSystemFactory(fishAnimation, timerFactory)
				if fishAnimationSystem == nil then
					return nil
				end

				fishAnimationSystem:Start()
				return fishAnimationSystem
			end

			local temp = { Current = { Value = 750 } }

			local function setupServer1(part)
				local toggle = false
				local timer = timerFactory(0.5)
				timer.TimeElapsed:Connect(function()
					if temp.Current.Value < 800 then
						part.BrickColor = BrickColor.new("Lime green")
						part.ImFine.Enabled = true
						part.WhyAmLagging.Enabled = false
						part.OMGSOLAGGYANDCRASHED.Enabled = false
					elseif temp.Current.Value > 800 and temp.Current.Value < 1600 then
						part.BrickColor = BrickColor.new("New Yeller")
						part.ImFine.Enabled = false
						part.WhyAmLagging.Enabled = true
						part.OMGSOLAGGYANDCRASHED.Enabled = false
					elseif temp.Current.Value > 1600 and temp.Current.Value < 2000 then
						part.BrickColor = BrickColor.new("Really red")
						part.ImFine.Enabled = false
						part.WhyAmLagging.Enabled = false
						part.OMGSOLAGGYANDCRASHED.Enabled = true
					elseif temp.Current.Value > 2000 then
						toggle = not toggle
						if toggle then
							part.Rip.Playing = true
							part.Sound.Playing = false
							part.BrickColor = BrickColor.new("Really black")
							part.ImFine.Enabled = false
							part.WhyAmLagging.Enabled = false
							part.OMGSOLAGGYANDCRASHED.Enabled = false
						else
							part.BrickColor = BrickColor.new("Really red")
							part.ImFine.Enabled = false
							part.WhyAmLagging.Enabled = false
							part.OMGSOLAGGYANDCRASHED.Enabled = true
						end
					end
				end)

				timer:Start()
				return timer
			end

			local function setupServer2(part)
				local timer = timerFactory(0.5)
				local toggle = false
				timer.TimeElapsed:Connect(function()
					if temp.Current.Value < 800 then
						part.BrickColor = BrickColor.new("Lime green")
						part.ImFine.Enabled = true
						part.WhyAmLagging.Enabled = false
						part.OMGSOLAGGYANDCRASHED.Enabled = false
					elseif temp.Current.Value > 800 and temp.Current.Value < 1600 then
						part.BrickColor = BrickColor.new("New Yeller")
						part.ImFine.Enabled = false
						part.WhyAmLagging.Enabled = true
						part.OMGSOLAGGYANDCRASHED.Enabled = false
					elseif temp.Current.Value > 1600 and temp.Current.Value < 2000 then
						part.BrickColor = BrickColor.new("Really red")
						part.ImFine.Enabled = false
						part.WhyAmLagging.Enabled = false
						part.OMGSOLAGGYANDCRASHED.Enabled = true
					elseif temp.Current.Value > 2000 then
						toggle = not toggle
						if toggle then
							part.BrickColor = BrickColor.new("Really red")
							part.ImFine.Enabled = false
							part.WhyAmLagging.Enabled = false
							part.OMGSOLAGGYANDCRASHED.Enabled = true
						else
							part.BrickColor = BrickColor.new("Really black")
							part.ImFine.Enabled = false
							part.WhyAmLagging.Enabled = false
							part.OMGSOLAGGYANDCRASHED.Enabled = false
						end
					end
				end)

				timer:Start()
				return timer
			end

			local function setupServer(model)
				return {
					Lights1 = setupServer1(model.ServerComputerLights1),
					Lights2 = setupServer2(model.ServerComputerLights2),
				}
			end

			local function setupColorMeRedBlue(model)
				local colorMeRedBlueGame = colorMeRedBlueFactory(model, playerStorage, 90, 30, tableHelper, timerFactory, timedGameFactory)

				-- Map the floor for the game
				local modelObjects = model:GetDescendants()
				for _, child in pairs(modelObjects) do
					if not child:IsA("BasePart") or not child.Name == "ColorMeRedBlue" then
						continue
					end

					local event = child.Touched:Connect(colorMeRedBlueGame.getTouchedEvent(child, colorMeRedBlueGame))
					if event == nil then
						continue
					end

					-- Register all long-lived instances in the top-level container
					table.insert(container, event)
				end

				colorMeRedBlueGame:Start()
				return colorMeRedBlueGame
			end

			local partEventActions = {
				Fish = setupFish,
				ColorMe = function(part)
					part.Touched:Connect(colorMe.getColorMeTouchedEvent(part))
				end,
				ColorMeP = function(part)
					part.Touched:Connect(privateRoom.getTouchedEvent(part))
				end,
				ColorChange = function(part)
					part.Touched:Connect(colorMe.getColorChangeTouchedEvent(part))
				end,
				ReturnPad = function(part)
					part.Touched:Connect(returnPad.getTouchedEvent(returnPoint))
				end,
				MatChangeX2ICE = setupMaterialChange,
				MatChangeX2COBBLE = setupMaterialChange,
				MatChangeX3PEBBLE = setupMaterialChange,
				MatChangeX4WOOD = setupMaterialChange,
				MatChangeX5FOIL = setupMaterialChange,
				MatChangeX6FORCE = setupMaterialChange,
				MatChangeX10NEON = setupMaterialChange,
				Doorway = setupDoor,
				N1persimmon = setupColorByNumber,
				N2brightorange = setupColorByNumber,
				N3olive = setupColorByNumber,
				N4brightgreen = setupColorByNumber,
				N5brightblue = setupColorByNumber,
				N6magenta = setupColorByNumber,
				N7earthgreen = setupColorByNumber,
				N8mulberry = setupColorByNumber,
				N9lapis = setupColorByNumber,
				N18redishbrown = setupColorByNumber,
			}

			local modelEventActions = {
				OfficeDoor = officeDoorFactory,
				Sink = SinkFactory,
				Server = setupServer,
				--RedBlueGroup = setupColorMeRedBlue,
			}

			for _, child in pairs(workspaceList) do
				local eventAction
				if child:IsA("BasePart") then
					eventAction = partEventActions[child.Name]
				end
				if child:IsA("Model") then
					eventAction = modelEventActions[child.Name]
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
			return container:Resolve("Workspace"):GetDescendants()
		end
	)

	-- Resolving the workspace mapping activates the workspace environment map
	container:Resolve("WorkspaceMapping")
end

return ColorMyWorldApp