--!nocheck
return function()
	local Container = require(script.Parent.Container)

	describe("registering type without type specified", function()
        --Arrange
        local container = Container.new()

        --Act
		local action = function()
            container:Register()
        end

        --Assert
		it("should throw an error", function()
			expect(action).to.throw()
		end)
	end)

	describe("registering new types after already resolving an instance from the container", function()
        --Arrange
        local container = Container.new()
        container:Register("Instance.Part")
		container:Resolve("Part")

        --Act
		local action = function()
            container:Register("MockType")
        end

        --Assert
		it("should throw an error", function()
			expect(action).to.throw()
		end)
	end)

	describe("resolving instance types without arguments from the container", function()
        --Arrange
        local container = Container.new()
        container:Register("Instance.Part")

        --Act
		local result = container:Resolve("Part")
        local instances = container:getAllInstances("Part")

        --Assert
		it("should return a new instance", function()
			expect(result.ClassName).to.equal("Part")
		end)
		it("should not store an instance in the container", function()
			expect(#instances).to.equal(0)
		end)
	end)

	describe("resolving instance types twice without arguments from the container", function()
        --Arrange
        local container = Container.new()
        container:Register("Instance.Part")

        --Act
		local result1 = container:Resolve("Part")
		local result2 = container:Resolve("Part")
        local instances = container:getAllInstances("Part")

        --Assert
		it("should generate two different instances in the container", function()
			expect(result1).to.never.equal(result2)
		end)
		it("should not store an instance in the container", function()
			expect(#instances).to.equal(0)
		end)
	end)

	describe("resolving global instance types wihtout arguments from the container", function()
        --Arrange
        local container = Container.new()
        container:Register("Instance.Part", {}, Container.GlobalLifetime)

        --Act
		local result = container:Resolve("Part")
        local instances = container:getAllInstances("Part")

        --Assert
		it("should store the instance in the container", function()
			expect(instances[1]).to.equal(result)
		end)
	end)

	describe("resolving global instance types wihtout arguments twice from the container", function()
        --Arrange
        local container = Container.new()
        container:Register("Instance.Part", {}, Container.GlobalLifetime)

        --Act
		local result1 = container:Resolve("Part")
		local result2 = container:Resolve("Part")
        local instances = container:getAllInstances("Part")

        --Assert
		it("should generate two different instances in the container", function()
			expect(result1).to.never.equal(result2)
		end)
		it("should store the first instance in the container", function()
			expect(instances[1]).to.equal(result1)
		end)
		it("should store the second instance in the container", function()
			expect(instances[2]).to.equal(result2)
		end)
	end)

	describe("resolving singleton types wihtout arguments from the container", function()
        --Arrange
        local container = Container.new()
        container:Register("Instance.Part", {}, Container.SingletonLifetime)

        --Act
		local result = container:Resolve("Part")
        local instances = container:getAllInstances("Part")

        --Assert
		it("should store the instance in the container", function()
			expect(instances[1]).to.equal(result)
		end)
	end)

	describe("resolving singleton types wihtout arguments twice from the container", function()
        --Arrange
        local container = Container.new()
        container:Register("Instance.Part", {}, Container.SingletonLifetime)

        --Act
		local result1 = container:Resolve("Part")
		local result2 = container:Resolve("Part")
        local instances = container:getAllInstances("Part")

        --Assert
		it("should return the same instance twice from the container", function()
			expect(result1).to.equal(result2)
		end)
		it("should store the instance in the container", function()
			expect(instances[1]).to.equal(result1)
		end)
		it("should not store a second instance in the container", function()
			expect(instances[2]).to.equal(nil)
		end)
	end)

	describe("resolving instance module types wihtout arguments from the container", function()
        --Arrange
        local container = Container.new()
        container:Register("MockType")

        --Act
		local result = container:Resolve("MockType")
        local instances = container:getAllInstances("MockType")

        --Assert
		it("should return a new instance with ClassName set", function()
			expect(result.ClassName).to.equal("MockType")
		end)
		it("should not store the instance in the container", function()
			expect(#instances).to.equal(0)
		end)
	end)

	describe("resolving singleton module types wihtout arguments twice from the container", function()
        --Arrange
        local container = Container.new()
        container:Register("MockType", {}, Container.SingletonLifetime)

        --Act
		local result1 = container:Resolve("MockType")
		local result2 = container:Resolve("MockType")
        local instances = container:getAllInstances("MockType")

        --Assert
		it("should return the same instance twice from the container", function()
			expect(result1).to.equal(result2)
		end)
		it("should store the instance in the container", function()
			expect(instances[1]).to.equal(result1)
		end)
		it("should not store a second instance in the container", function()
			expect(instances[2]).to.equal(nil)
		end)
	end)
end