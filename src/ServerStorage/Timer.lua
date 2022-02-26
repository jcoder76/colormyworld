local Timer = {}
Timer.__index = Timer

local Type = require(script.Parent.Type)
local IntervalProvider = require(script.Parent.IntervalProvider)

local function waitEvent(event, time)
	local result, connection
	connection = event:connect(function(...)
		local args = {...}
		result = {n = select("#", args), unpack(args)}
		connection:disconnect()
	end)

	time = tick() + (time or 30)
	repeat
		wait()
	until result or tick() > time

	if not result then
		return false, connection:disconnect()
	end

	return true, unpack(result, 1, result.n)
end

-- Creates a new timer, by default context can either be a number or
-- an implementation of IntervalProvider
function Timer.new(context, ...)
	local args = {...}
	local self = setmetatable({}, Timer)
	local interval = 0
	local intervalMethod: (any) -> number
	if Type.Is(context, "number") then
		interval = context
		intervalMethod = nil
	elseif Type.Implements(context, IntervalProvider) then
		interval = context:Interval()
		intervalMethod = function(c)
			return c:Interval()
		end
	end
	local timerSettings = {
		IsRunning = false,
		__context = context,
		__interval = interval,
		__intervalMethod = intervalMethod,
		__pauseEvent = Instance.new("BindableEvent"),
		__timeElapsedEvent = Instance.new("BindableEvent"),
		__isDisposed = false,
		__isStopping = false,
	}
	self.Settings = timerSettings
	self.TimeElapsed = timerSettings.__timeElapsedEvent.Event
	self.__thread = coroutine.wrap(function(_self)
		_self.IsRunning = true
		while not _self.__isDisposed and not _self.__isStopping do
			-- Try to retireve the current interval if the context implements IntervalProvider
			local currentInterval = _self.__interval
			if _self.__intervalMethod ~= nil then
				currentInterval = _self.__intervalMethod(_self.__context)
			end
			-- Wait for the next time elapsed event
			_self.__timeElapsedEvent:Fire(_self.__context, unpack(args))
			if _self.__isDisposed then
				continue
			end
			local pause, _ = waitEvent(_self.__pauseEvent.Event, currentInterval)
			-- If we need to pause the timer
			if pause then
				_self.IsRunning = false
				coroutine.yield()
				_self.IsRunning = true
			end
		end
		_self.IsRunning = false
	end)
	return self
end

function Timer:Interval(): number
	return self.Settings.__interval
end

function Timer:IsRunning(): boolean
	return self.Settings.IsRunning
end

function Timer:IsDisposed(): boolean
	return self.Settings.__isDisposed
end

function Timer:Start()
	if self:IsDisposed() or self:IsRunning() then
		return
	end

	self:__wakeUp()
	return self
end

function Timer:Pause()
	if self:IsDisposed() or not self:IsRunning() then
		return
	end

	self.Settings.__pauseEvent:Fire()
	return self
end

function Timer:Dispose()
	if self:IsDisposed() then
		return
	end

	self:Pause()
	self.Settings.__isDisposed = true
	-- Wake up timer coroutine to end it
	self:__wakeUp()
	return self
end

function Timer:__wakeUp()
	pcall(self.__thread, self.Settings)
end

return Timer
