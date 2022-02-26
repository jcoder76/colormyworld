local AnimationSystem = {}
AnimationSystem.__index = AnimationSystem

function AnimationSystem.new(animation, timerFactory)
    if not animation or not timerFactory then
        return nil
    end
    local self = setmetatable({}, AnimationSystem)
    self.Timer = timerFactory(animation)
    self.Timer.TimeElapsed:Connect(function(_self)
        _self:NextStep()
    end)
    return self
end

function AnimationSystem:Start()
    self.Timer:Start()
end

return AnimationSystem