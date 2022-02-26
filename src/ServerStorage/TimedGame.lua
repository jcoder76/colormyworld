local TimedGame = {}
TimedGame.__index = TimedGame

local GameState = require(script.Parent.GameState)

local function handleTimeElapsed(context, gameState, _timerUpdatedEvent)
	local prestart = gameState.GamePrestart
	if prestart > 0 then
		prestart = prestart + 0.999
		local prestartTime = math.ceil(tick() - gameState.StartTime - prestart)
		if prestartTime <= 0 then
			_timerUpdatedEvent:Fire(context, gameState, prestartTime)
			return
		end
	end

	gameState:StartGame()
	local timeLeft = math.floor(gameState.GameLength + prestart + gameState.StartTime - tick() + 0.999)
	if timeLeft > 0 then
		_timerUpdatedEvent:Fire(context, gameState, timeLeft)
		return
	end

	gameState:EndGame()
end

function TimedGame.new(context: any, gameLength: number, gamePrestart: number?, timerFactory: (any, ...any)->any)
	local self = setmetatable({}, TimedGame)
	self.GameState = GameState.new(context, gameLength, gamePrestart)
	self.GameStarted = self.GameState.GameStarted
	self.GameEnded = self.GameState.GameEnded
	self.__timerUpdatedEvent = Instance.new("BindableEvent")
	self.TimerUpdated = self.__timerUpdatedEvent.Event
	local Timer = require(script.Parent.Timer)
	if timerFactory == nil then
		timerFactory = Timer.new
	end
	self.GameTimer = timerFactory(context, self.GameState, self.__timerUpdatedEvent)
	self.GameTimer.TimeElapsed:Connect(handleTimeElapsed)
	return self
end

function TimedGame:IsGameStarted()
	return self.GameState.IsGameStarted
end

function TimedGame:StartCounter()
	if self.GameTimer:IsRunning() then
		return
	end
	self.GameState:UpdateGameStart()
	self.GameTimer:Start()
end

function TimedGame:StartGame()
	self.GameState:StartGame()
end

function TimedGame:ResetCounter()
	self.GameState:UpdateGameStart()
end

function TimedGame:StopCounter()
	self.GameTimer:Pause()
	self.GameState:ResetGameStart()
end

function TimedGame:EndGame()
	self.GameState:EndGame()
end

function TimedGame:Dispose()
	self:StopCounter()
	self.GameTimer:Dispose()
end

return TimedGame
