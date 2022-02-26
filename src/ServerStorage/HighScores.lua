local HighScores = {
	highScoreList = {}
}

local MAX_SCORES = 5
	
local newEvent = Instance.new("BindableEvent")
HighScores.ScoresChangedEvent = newEvent
HighScores.ScoresChanged = newEvent.Event

function HighScores:updateScore(player, points)
	if not player or not points then
		return
	end
	
	-- Remove the player's high score
	for i, highScore in ipairs(self.highScoreList) do
		if player.Name == highScore.Name then
			table.remove(self.highScoreList, i)
			break
		end
	end
	
	-- Find our place in the high scores
	local insertAt = 0
	for i, highScore in ipairs(self.highScoreList) do
		if points > highScore.Score then
			insertAt = i
			break
		end
	end
	
	-- If not high place found try to add to bottow
	if insertAt < 1 then
		if #self.highScoreList >= MAX_SCORES then
			return
		end
		
		table.insert(self.highScoreList, {Name = player.Name, Score = points})
		self.ScoresChangedEvent:Fire(self.highScoreList)
		
		return
	end
	
	-- We are a higher score try to insert above
	table.insert(self.highScoreList, insertAt, {Name = player.Name, Score = points})
	while #self.highScoreList > MAX_SCORES do
		table.remove(self.highScoreList)
	end
	self.ScoresChangedEvent:Fire(self.highScoreList)
end

return HighScores
