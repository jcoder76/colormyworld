--!strict
local Container = {}
Container.__index = Container
Container.DefaultResolveRoot = "ServerStorage"

-- Gets the instance list for the given type
function Container:getAllInstances(typeName: string): {any}
    if not self.container[typeName] then
        self.container[typeName] = {}
    end

    return self.container[typeName]
end

-- Defines a type to have a global lifetime
function Container:addInstance(typeName: string, instance: any)
    if not instance then
        return
    end
    local instances = self:getAllInstances(typeName)
    table.insert(instances, instance)
end

-- Defines a type to have a global lifetime
function Container:getInstance(typeName: string): any
    if typeName == "" then
        return nil
    end
    local instances = self:getAllInstances(typeName)
    if #instances <= 0 then
        return nil
    end
    return instances[1]
end

-- Defines a type to have a local lifetime with many instances
function Container.InstanceLifetime(container: Container, typeName: string): any
    -- Instance lifetime always generates a new instance for a transient
    -- lifetime, this is default behavior
    if not container or typeName == "" then
        return nil
    end
    return container:createInstance(typeName)
end

-- Defines a type to have a global lifetime with many instances
function Container.GlobalLifetime(container: Container, typeName: string): any
    -- Global lifetime always generates a new instance but adds all instances
    -- to the container for a container lifetime
    if not container or typeName == "" then
        return nil
    end
    local instance = container:createInstance(typeName)
    container:addInstance(typeName, instance)
    return instance
end

-- Defines a type to have a singleton lifetime with only a single instance
function Container.SingletonLifetime(container: Container, typeName: string): any
    -- Singleton lifetime only generates a new instance if one doesn't already
    -- exist in the container having in effect a container singleton lifetime
    if not container or typeName == "" then
        return nil
    end
    local instance = container:getInstance(typeName)
    if instance then
        return instance
    end
    instance = container:createInstance(typeName)
    container:addInstance(typeName, instance)
    return instance
end

-- Gets a default constructor for the given type if none is provided
function Container:getDefaultConstructor(typePath: string): (any) -> any
    local typeNames = typePath:split(".")
    local parentTypes: {string} = {}
    if #typeNames <= 1 then
        table.insert(parentTypes, Container.DefaultResolveRoot)
    else
        for index = 1, #typeNames - 1 do
            table.insert(parentTypes, typeNames[index])
        end
    end
    if parentTypes[1] == "Instance" then
        return function ()
            return Instance.new(typeNames[#typeNames])
        end
    end
    -- Normalize the type name
    local typeName = ""
    if #typeNames > 0 then
        typeName = typeNames[#typeNames]
    end
    return function (...): any
        local parentInstance = self:Resolve(parentTypes[1])
        for index = 2, #parentTypes do
            parentInstance = parentInstance:WaitForChild(parentTypes[index], 60)
        end
        if typeName == "" then
            return parentInstance
        end
        local instance: any = parentInstance:WaitForChild(typeName, 60)
        if not instance then
            error("Unable to resolve type '" .. typeName .. "'.")
        end
        if not instance.ClassName or instance.ClassName ~= "ModuleScript" then
            return instance
        end

        -- Assume if a new method exists we want an instance generated
        -- otherwise return the module itself
        local moduleInstance = require(instance)
        instance = moduleInstance
        if moduleInstance.new then
            instance = moduleInstance.new(...)
            if typeof(instance) == "table" then
                instance.Module = moduleInstance
            end
        end
        -- If an instance is generated, bind type info to the instance
        if not instance then
            error("Instance constructor for module " .. typeName .. " returned nil.")
        end
        if typeof(instance) ~= "table" then
            return instance
        end
        instance.ClassName = typeName
        return instance
    end
end

-- Registers the type path and its construction method into the container
function Container:Register(typePath: string, argumentTypes: {string}, lifetime: (Container, string) -> any, constructor: (any) -> any): Container
    if self.isResolved then
        error("Cannot register new types when types have been resolved")
    end
    if typePath == "" then
        error("Type not given in attempt to register")
    end
    local typeAliasPair = typePath:split(":")
    if #typeAliasPair > 2 then
        error("Defining More than one type alias (':[type]') is not permitted")
    end
    typePath = typeAliasPair[1]
    local typeNames = typePath:split(".")
    local typeAlias = typeNames[#typeNames]
    if #typeAliasPair > 1 then
        typeAlias = typeAliasPair[2]
    end
    if not constructor then
        constructor = self:getDefaultConstructor(typePath)
    end
    if not argumentTypes then
        argumentTypes = {}
    end
    if not lifetime then
        lifetime = Container.InstanceLifetime
    end

    self.typeRegistration[typeAlias] = {
        ArgumentTypes = argumentTypes,
        TypeConstructor = constructor,
        Lifetime = lifetime
    }

    return self
end

-- Registers the full or partial type path relative to the workspace root and its construction method into the container
function Container:RegisterWorkspace(typePath: string, argumentTypes: {string}, lifetime: (Container, string) -> any, constructor: (any) -> any): {}
    if typePath == "" then
        typePath = "Workspace"
    else
        typePath = "Workspace." .. typePath
    end
    self:Register(typePath, argumentTypes, lifetime, constructor)
    return self
end

function Container:RegisterMap(typeName: string, instanceName: string)
    if not self.typeRegistration[typeName] then
        error("Must register the type '" .. typeName .. "' first before adding an instance mapping.")
    end
    if self.isResolved then
        error("Cannot register new instance mappings when types have been resolved")
    end
    self.instanceMap[instanceName] = typeName
end

function Container:GetTypeMap(instance: any): string
    if not instance or not instance.Name then
        return ""
    end
    local typeName = instance.Name or instance.ClassName or typeof(instance)
    return self.instanceMap[typeName]
end

-- Resolves a registered type with its instance generator
function Container:Resolve(typeName: string): any
    self.isResolved = true
    if not typeName then
        return nil
    end
    local returnFactory = false
    if string.sub(typeName, 1, 2) == "->" then
        returnFactory = true
        typeName = string.sub(typeName, 3)
    end
    local typeRegistration = self.typeRegistration[typeName]
    if not typeRegistration then
        error("Type ".. typeName .." was not registered in the container.")
    end
    if returnFactory then
        return typeRegistration.TypeConstructor
    end
    return typeRegistration.Lifetime(self, typeName)
end

-- Resolves types in the instance map matching the given source
function Container:ResolveMap(source: {any}): {any}
    local map = {}
    for _, sourceItem in ipairs(source) do
        table.insert(map, self:Resolve(self:GetTypeMap(sourceItem)))
    end

    return map
end

-- Creates a new instance of the given type from the type registrations
function Container:createInstance(typeName: string): any
    local typeRegistration = self.typeRegistration[typeName]
    if not typeRegistration then
        error("Type '" .. typeName .. "' was not registered")
    end
    local arguments = {}
    for _, argumentType in ipairs(typeRegistration.ArgumentTypes) do
        if argumentType == typeName then
            error("Type '" .. typeName .. "' cannot be resolved because it requires an argument of the same type")
        end
        table.insert(arguments, self:Resolve(argumentType))
    end
    return typeRegistration.TypeConstructor(unpack(arguments))
end

-- Creates a new instance of the container
function Container.new(resolveRoot: any): Container
    local self = setmetatable({}, Container)
    if resolveRoot == nil then
        resolveRoot = Container.DefaultResolveRoot
    end
    self.resolveRoot = resolveRoot
    self.isResolved = false
    self.container = {}
    self.typeRegistration = {}
    self.instanceMap = {}
    self:Register("ServerStorage", {}, Container.SingletonLifetime, function()
        return game:GetService("ServerStorage")
    end)
    self:Register("Workspace", {}, Container.SingletonLifetime, function()
        return game:GetService("Workspace")
    end)
    return self
end

type Container = typeof(Container.new())

return Container