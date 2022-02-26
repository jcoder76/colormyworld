--!nocheck
return function()
	local TimedGame = require(script.Parent.TimedGame)

	-- Then we validate our module behavior expectations
	describe("timed game is created", function()
		local timedGame = TimedGame.new(1, 3)

		it("should have GameLength in GameState set to 3", function()
			expect(timedGame.GameState.GameLength).to.equal(3)
		end)

		it("should have GameTimer Interval set to 1", function()
			expect(timedGame.GameTimer:Interval()).to.equal(1)
		end)
    end)

    describe("timed game set to end in 3 seconds", function()
        local receivedEvent = false
		local timedGame = TimedGame.new(1, 2)
		timedGame.TimerUpdated:Connect(function()
			receivedEvent = true
		end)
		timedGame:StartCounter()
		wait(3)
        timedGame:Dispose()

		it("should call timer updated event after 3 seconds", function()
			expect(receivedEvent).to.equal(true)
		end)
    end)
end