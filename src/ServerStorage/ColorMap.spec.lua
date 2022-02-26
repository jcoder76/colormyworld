--!nocheck
return function()
	local ColorMap = require(script.Parent.ColorMap)
	local TestMocks = require(script.Parent.TestMocks)

	-- Then we validate our module behavior expectations
	describe("color map is created", function()
		local colorMap = ColorMap.new("TestGroup")

		it("should have name TestGroup", function()
			expect(colorMap.Name).to.equal("TestGroup")
		end)

		it("should be in a not completed state", function()
			expect(colorMap.IsCompleted).to.equal(false)
		end)

		it("should have no parts assigned", function()
			expect(#colorMap.PartsAssigned).to.equal(0)
		end)

        it("should have a BindableEvent called MapCompletedEvent", function()
            expect(colorMap.MapCompletedEvent.ClassName).to.equal("BindableEvent")
		end)

        it("should map the event signal for MapCompletedEvent to MapCompleted", function()
            expect(typeof(colorMap.MapCompleted)).to.equal("RBXScriptSignal")
        end)
    end)

	describe("color mapping added", function()
		local player = {UserId = "TestId1", Name = "TestPlayer", Character = Instance.new("Humanoid")}
		local group = TestMocks.getColorByNumberMock("TestGroup1")
		local colorMap = ColorMap.new()

		it("should have a mapping added", function()
			colorMap:addMapping(player, group.TestPart1, nil)

			expect(#colorMap.PartsAssigned).to.equal(1)
		end)
	end)

	describe("color map completed", function()
		local colorMap = ColorMap.new("TestGroup")

		it("should raise the MapCompleted event", function()
			local eventReceived = false
			colorMap.MapCompleted:Connect(function()
				eventReceived = true
			end)

			colorMap:completed()

			expect(eventReceived).to.equal(true)
		end)
	end)

	describe("color map reset", function()
		local colorMap = ColorMap.new("TestGroup")

		it("should keep map updataed event bound", function()
			local eventReceived = false
			colorMap.MapCompleted:Connect(function()
				eventReceived = true
			end)

			-- When a reset occurs it must not unbind the event
			colorMap:reset()
			colorMap:completed()

			expect(eventReceived).to.equal(true)
		end)
	end)

	describe("color map connect once", function()
		local colorMap = ColorMap.new("TestGroup")

		it("should connect map updataed event only once", function()
			local eventsReceived = 0
			colorMap:ConnectOnce(function()
				eventsReceived = eventsReceived + 1
			end)
			colorMap:ConnectOnce(function()
				eventsReceived = eventsReceived + 1
			end)

			colorMap:completed()

			expect(eventsReceived).to.equal(1)
		end)
	end)

	describe("color map disconnect", function()
		local colorMap = ColorMap.new("TestGroup")

		it("should disconnect map updataed event", function()
			local eventReceived = false
			colorMap:ConnectOnce(function()
				eventReceived = true
			end)
			colorMap:Disconnect()

			colorMap:completed()

			expect(eventReceived).to.equal(false)
		end)
	end)
end