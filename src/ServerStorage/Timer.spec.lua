--!nocheck
return function()
	local Timer = require(script.Parent.Timer)

	-- Then we validate our module behavior expectations
	describe("timer is created", function()
		local timer = Timer.new(2)

		it("should have Interval set to 2", function()
			expect(timer:Interval()).to.equal(2)
		end)

		it("should have IsRunning set to false", function()
			expect(timer:IsRunning()).to.equal(false)
		end)

        it("should have a BindableEvent called __timeElapsedEvent", function()
            expect(timer.Settings.__timeElapsedEvent.ClassName).to.equal("BindableEvent")
		end)

        it("should map the event signal for TimeElapsedEvent to TimeElapsed", function()
            expect(typeof(timer.TimeElapsed)).to.equal("RBXScriptSignal")
        end)
    end)

	describe("wait for started timer with 2s interval", function()
		local timer = Timer.new(2)
		local receivedEvent = false
		timer.TimeElapsed:Connect(function()
			receivedEvent = true
		end)
		timer:Start()
		wait(3)
		timer:Dispose()

		it("should raise TimeElapsed event", function()
			expect(receivedEvent).to.equal(true)
		end)
	end)
end