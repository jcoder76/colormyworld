local ReplicatedStorage = game:GetService("ReplicatedStorage")
local setPaintStateEvent = ReplicatedStorage:WaitForChild("SetPaintStateEvent")
local button = script.Parent
local paintEnabled = true

button.Activated:Connect(function()
	paintEnabled = not paintEnabled
	if paintEnabled then
		button.Image = "rbxgameasset://Images/PaintOn"
	else		
		button.Image = "rbxgameasset://Images/PaintOff"
	end
	
	setPaintStateEvent:FireServer(paintEnabled)
end)