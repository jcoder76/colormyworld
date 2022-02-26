return function()
	local Type = require(script.Parent.Type)

	-- Then we validate our module behavior expectations
	describe("if type does implement interface", function()
        local source = {}
        function source:TestFunc()
            print("Hello World")
        end
        -- Interfaces can be one-liner function list definitions
        local interface = {
            TestFunc = function() end,
        }
		it("should return true", function()
			expect(Type.Implements(source, interface)).to.equal(true)
		end)
    end)

	describe("if type does not implement interface", function()
        local source = {}
        function source:SomeOtherFunc()
            print("Hello World")
        end
        -- Interfaces can be one-liner function list definitions
        local interface = {
            TestFunc = function() end,
        }
		it("should return false", function()
			expect(Type.Implements(source, interface)).to.equal(false)
		end)
	end)

	describe("if type does have member", function()
        local source = {
            Test1 = 1
        }
		it("should return true", function()
			expect(Type.HasMember(source, "Test1")).to.equal(true)
		end)
	end)

	describe("if type does not have member", function()
        local source = {}
		it("should return false", function()
			expect(Type.HasMember(source, "Test1")).to.equal(false)
		end)
	end)

	describe("if type is primitive and does not have member", function()
        local source = 1
		it("should return false", function()
			expect(Type.HasMember(source, "Test1")).to.equal(false)
		end)
	end)

	describe("if type is a number primitive", function()
        local source = 3
		it("should return true", function()
			expect(Type.Is(source, "number")).to.equal(true)
		end)
    end)
end