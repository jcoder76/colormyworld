--!nocheck
return function()
	local ColorMe = require(script.Parent.ColorMe)

	describe("get ColorMe touched event", function()
		local model = Instance.new("Part")
		local result = ColorMe.getColorMeTouchedEvent(model)

		it("should return a function", function()
			expect(type(result)).to.equal("function")
		end)
	end)

	describe("get ColorChange touched event", function()
		local model = Instance.new("Part")
		local result = ColorMe.getColorChangeTouchedEvent(model)

		it("should return a function", function()
			expect(type(result)).to.equal("function")
		end)
	end)

	describe("get MaterialChange touched event", function()
		local model = Instance.new("Part")
		local result = ColorMe.getMaterialChangeTouchedEvent(model, 1)

		it("should return a function", function()
			expect(type(result)).to.equal("function")
		end)
	end)
end