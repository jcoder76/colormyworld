--!nocheck
return function()
	local TestMocks = require(script.Parent.TestMocks)

	-- First we validate our mocks are correct
	describe("color by number mock", function()
		-- Get the group map
		local group = TestMocks.getColorByNumberMock("TestGroup")
		local part1 = group.TestPart1
		local part2 = group.TestPart2

		it("should be an instance of a model", function()
			expect(group.ClassName).to.equal("Model")
		end)

		it("should be called TestGroup", function()
			expect(group.Name).to.equal("TestGroup")
		end)

		it("should have a part called TestPart1", function()
			expect(part1.ClassName).to.equal("Part")
		end)

		it("should have a part called TestPart2", function()
			expect(part2.ClassName).to.equal("Part")
		end)
	end)
end