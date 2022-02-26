local GameState = {}
GameState.__index = GameState

function GameState.new(context:any, gameLength: number, gamePrestart: number?)
	local self = setmetatable({}, GameState)
	if gamePrestart == nil then
		gamePrestart = 0
	end
    self.Context = context
	self.IsGameStarted = false
	self.GameStartedEvent = Instance.new("BindableEvent")
	self.GameStarted = self.GameStartedEvent.Event
	self.GameEndedEvent = Instance.new("BindableEvent")
	self.GameEnded = self.GameEndedEvent.Event
	self.GamePrestart = gamePrestart
	self.GameLength = gameLength
	self.StartTime = 0
	return self
end

function GameState:StartGame()
	if self.IsGameStarted then
		return
	end
	self.IsGameStarted = true
	self.GameStartedEvent:Fire(self)
end

function GameState:UpdateGameStart()
	self.StartTime = tick()
end

function GameState:ResetGameStart()
	self.StartTime = 0
end

function GameState:EndGame()
	if not self.IsGameStarted then
		return
	end
	self.IsGameStarted = false
	self.GameEndedEvent:Fire(self)
	self:ResetGameStart()
end

return GameState
