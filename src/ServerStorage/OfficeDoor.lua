--!strict
local OfficeDoor = {}
OfficeDoor.__index = OfficeDoor

local function setVisibleState(part, isVisible)
    part.CanCollide = isVisible
    if isVisible then
        part.Transparency = 0
        return
    end
	part.Transparency = 1
end

function OfficeDoor.new(model: any): OfficeDoorType
    local self = setmetatable({}, OfficeDoor)

    -- Default instance for type system.
    if not model then
        self.Model = Instance.new("Model")
        self.IsOpen = false
        self.PartsClosed = {}
        self.PartsOpen = {}
        return self
    end

    local config = model:FindFirstChild("Configuration")
    if not config or config.ClassName ~= "Configuration" then
        return nil
    end

    local doorOpen = config:FindFirstChild("DoorOpen")
    if not doorOpen or doorOpen.ClassName ~= "BoolValue" then
        return nil
    end

    self.Model = model
    self.IsOpen = doorOpen.Value
    self.PartsClosed = { model:FindFirstChild("Door1"), model:FindFirstChild("Handle1") }
    self.PartsOpen = { model:FindFirstChild("Door2"), model:FindFirstChild("Handle2") }

    local function onHandleClicked()
        self.IsOpen = not self.IsOpen
        self:UpdateDoorState()
    end

    model.Handle1.ClickDetector.MouseClick:Connect(onHandleClicked)
    model.Handle2.ClickDetector.MouseClick:Connect(onHandleClicked)

    return self
end

function OfficeDoor:Closed()
	self.IsOpen = false
	self:UpdateDoorState()
end

function OfficeDoor:Open()
	self.IsOpen = true
	self:UpdateDoorState()
end

function OfficeDoor:UpdateDoorState()
    for _, part in ipairs(self.PartsOpen) do
        setVisibleState(part, self.IsOpen)
    end
    for _, part in ipairs(self.PartsClosed) do
        setVisibleState(part, not self.IsOpen)
    end
end

export type OfficeDoorType = typeof(OfficeDoor.new())

return OfficeDoor