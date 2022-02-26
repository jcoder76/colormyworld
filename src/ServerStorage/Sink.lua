local Sink = {}
Sink.__index = Sink

function Sink.new(model)
    local self = setmetatable({}, Sink)
    self.IsOn = false
    self.Model = model
    self.Water = model.Model.Water

    model.Button.ClickDetector.MouseClick:Connect(function()
        self.IsOn = not self.IsOn
        self:UpdateSink()
    end)
    return self
end

function Sink:On()
    self.IsOn = true
    self:UpdateSink()
end


function Sink:Off()
    self.IsOn = false
    self:UpdateSink()
end

function Sink:UpdateSink()
    local water = self.Water
    local isOn = self.IsOn
    water.ParticleEmitter.Enabled = isOn
    if isOn then
        water.Sound:Play()
        return
    end

    water.Sound:Stop()
end

return Sink