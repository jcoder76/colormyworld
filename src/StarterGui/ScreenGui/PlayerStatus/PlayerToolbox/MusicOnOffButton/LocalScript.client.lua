local music = workspace.RoseColoredGlasses
local button = script.Parent
local musicEnabled = true
 
button.Activated:Connect(function()
	musicEnabled = not musicEnabled
	if musicEnabled then
		button.Image = "rbxgameasset://Images/MusicOn"
		music.Volume = 0.3
	else		
		button.Image = "rbxgameasset://Images/MusicOff"
		music.Volume = 0
	end
end)
