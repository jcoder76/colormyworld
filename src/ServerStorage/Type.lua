--!strict
local Type = {}
Type.__index = Type

function Type.Is(source: any, typeName: string): boolean
    return source ~= nil and typeName ~= nil and
        ((Type.HasMember(source, "ClassName") and source.ClassName == typeName) or type(source) == typeName or typeof(source) == typeName or
        (Type.HasMember(source, "IsA") and Type.IsFunction(source.IsA) and source:IsA(typeName) == true))
end

function Type.Implements(source: any, interface: any): boolean
    -- A nil value is never an acceptable source or interface
    if source == nil or interface == nil then
        return false
    end

    -- Ensure all the methods in the interface contract are implemented
    local sourceMetatable = getmetatable(source)
    for key, value in pairs(interface) do
        if not Type.IsFunction(value) then
            continue
        end
        if (not Type.HasMember(source, key) or not Type.IsFunction(source[key])) and
            (not Type.HasMember(sourceMetatable, key) or not Type.IsFunction(sourceMetatable[key])) then
            return false
        end
    end

    -- If we made it this far there are no unimplemented features of the target interface
    return true
end

function Type.HasMember(source: any, memberName: string): boolean
    if source == nil or memberName == "" then
        return false
    end
    local success: boolean
    local result: any
    local sourceMetatable = getmetatable(source)
    success, result = pcall(function()
        return source[memberName] ~= nil or (sourceMetatable ~= nil and sourceMetatable[memberName] ~= nil)
    end)

    return success == true and result == true
end

function Type.IsFunction(source: any): boolean
    return source ~= nil and type(source) == "function"
end

return Type