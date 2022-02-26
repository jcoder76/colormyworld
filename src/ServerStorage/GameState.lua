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

	self.StartGame = function(_self)
		if _self.IsGameStarted then
			return
		end
		_self.IsGameStarted = true
		_self.GameStartedEvent:Fire(_self)
	end

	self.EndGame = function(_self)
		if not _self.IsGameStarted then
			return
		end
		_self.IsGameStarted = false
		_self.GameEndedEvent:Fire(_self)
		_self:ResetGameStart()
	end

	self.ResetGameStart = function(_self)
		_self.StartTime = 0
	end

	return self
end

function GameState:UpdateGameStart()
	self.StartTime = tick()
end

return GameState
