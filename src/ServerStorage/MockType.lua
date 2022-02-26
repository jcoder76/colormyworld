--!strict
local MockType = {}
MockType.__index = MockType

function MockType.new(): MockType
    local self = setmetatable({}, MockType)
    return self
end

export type MockType = typeof(MockType.new())

return MockType