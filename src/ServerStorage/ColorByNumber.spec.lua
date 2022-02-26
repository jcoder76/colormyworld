--!nocheck
return function()
	local ColorByNumber = require(script.Parent.ColorByNumber)
	local TestMocks = require(script.Parent.TestMocks)

	-- Then we validate our module behavior expectations
	describe("color map is created", function()
		local colorMap = ColorByNumber:getColorMap("TestMap1")

		it("should be a table", function()
			expect(type(colorMap)).to.equal("table")
		end)
    end)

	describe("get ColorByNumber touched event", function()
		local model = TestMocks.getColorByNumberMock("TestGroup1")
		local part = model.TestPart1
		local result = ColorByNumber.getTouchedEvent(part)

		it("should return a function", function()
			expect(type(result)).to.equal("function")
		end)

		it("should hook the map completed event", function()
			expect(type(result)).to.equal("function")
		end)
	end)

	describe("color map is retrieved", function()
		-- Get the map and set the completed state whixh is by default false
		local colorMap1 = ColorByNumber:getColorMap("TestMap2")
		colorMap1.IsCompleted = true

		it("should be same when retrieved twice", function()
			local colorMap2 = ColorByNumber:getColorMap("TestMap2")

			expect(colorMap2.IsCompleted).to.equal(true)
		end)
    end)

	describe("color map updated", function()
		-- Get the map and set the completed state whixh is by default false
		local player = {UserId = "TestId1", Name = "TestPlayer", Character = Instance.new("Humanoid")}
		local group = TestMocks.getColorByNumberMock("TestGroup1")
		local colorMap = ColorByNumber:getColorMap(group.Name)

		it("should have a mapping added", function()
			ColorByNumber:updateColorMap(player, group.TestPart1, nil)

			expect(#colorMap.PartsAssigned).to.equal(1)
		end)
	end)

	describe("color map reset", function()
		local colorMap1 = ColorByNumber:getColorMap("TestGroup2")

		it("should be the same map", function()
			-- When a reset occurs it must not replace the
			-- map with a new instance or events will be lost
			-- NOTE: We retrieve the map again in case we get a new instance
			ColorByNumber:reset("TestGroup2")
			local colorMap2 = ColorByNumber:getColorMap("TestGroup2")

			expect(colorMap2).to.equal(colorMap1)
		end)
	end)
end