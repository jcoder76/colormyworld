local Animation = {}
Animation.__index = Animation

function Animation.new(frames, model)
    if not model or type(frames) ~= "table" or #frames < 1 then
        return nil
    end
    local self = setmetatable({}, Animation)
    self.Frames = frames
    self.Model = model
    self.Index = 1
    return self
end

-- implement interface Timer.IntervalProvider
function Animation:Interval()
    return self.Frames[self.Index].Delay
end

function Animation:NextStep()
    local frame = self.Frames[self.Index]
    frame.Action(self.Model)
    self.Index = self.Index + 1
    if self.Index > #self.Animations then
        self.Index = 1
    end
end

return Animation