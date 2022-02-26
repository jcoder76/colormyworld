--!nocheck
return function()
	local ColorMeRedBlue = require(script.Parent.ColorMeRedBlue)
	local TestMocks = require(script.Parent.TestMocks)
	local Table = require(script.Parent.Table)
	local Timer = require(script.Parent.Timer)
	local TimedGame = require(script.Parent.TimedGame)

	-- Then we validate our module behavior expectations
	describe("ColorMeRedBlue object is created", function()
		local testModel = TestMocks.getColorMeRedBlueMock()
		local testControllerFactory = function()
			return {}
		end
		local testTimerFactory = function(context)
			return Timer.new(context)
		end
		local testTimedGameFactory = function(context)
			return TimedGame.new(context, 1, 1, testTimerFactory)
		end
		local colorMeRedBlue = ColorMeRedBlue.new(testModel, {}, 1, 0,
			Table, testControllerFactory, nil, testTimedGameFactory)

		it("should be a table", function()
			expect(type(colorMeRedBlue)).to.equal("table")
		end)
    end)
end