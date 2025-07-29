local Event = require(script.Parent.Event)
local Switch = require(script.Parent.Parent.Parent.UtilModules.Switch)
local HttpService = game:GetService("HttpService")

local Container = {}
Container.Wrappers = {} :: { [string]: FunctionWrapper }

local ERROR_WRAPPER_NAME_USED = "Wrapper name \"%s\" is already in use!"
local ERROR_REQUIRED_PROPERTY_EMPTY = "Required property \"%s\" is nil or empty!"
local ERROR_ARGUMENT_COUNT_INVALID = "Function frame \"%s\" has %s arguments provided when it should have %s."

--[=[
    Creates a FunctionFrame for a given wrapper.

    @param self The FunctionWrapper to be used
    @param extension The paramaters of the function

    @return A new FunctionFrame with the provided paramaters
]=]
local function Extend(self: FunctionWrapper, extension: { [number]: any }): FunctionFrame
    assert(#extension == #self.Arguments, string.format(ERROR_ARGUMENT_COUNT_INVALID, self.Name, #extension or 0, #self.Arguments))

    local serializedExtension = {}
    
    local frame: FunctionFrame = {
        Name = self.Name,
        Extension = serializedExtension,
        Dependencies = self.Dependencies,
        DataReferenceCache = {},
    }
    
    for i, v in extension do
        local dataType = typeof(v)
        
        Switch.Evaluate(dataType)
        :Case("string", function()
            serializedExtension[i] = `"{v}"`
        end)
        :Case("boolean")
        :Case("number", function()
            local stringified = tostring(v)
            serializedExtension[i] = stringified
        end)
        :Case("Color3", function()
            serializedExtension[i] = `Color3.fromHex({v:ToHex()})`
        end)
        :Case("NumberRange", function()
            serializedExtension[i] = `NumberRange.new({tostring(v.Min)}, {tostring(v.Max)})`
        end)
        :Case("Vector3")
        :Case("Vector2", function()
            serializedExtension[i] = `{dataType}.new({tostring(v)})`
        end)
        :Case("EnumItem", function()
            serializedExtension[i] = `Enum.{tostring(v.EnumType)}.{v.Name}`
        end)
        :Case("Instance")
        :Case("CFrame", function()
            local uuid = HttpService:GenerateGUID()
            frame.DataReferenceCache[uuid] = v
            serializedExtension[i] = `script.References[{uuid}].Value`
        end)
        :Case("ColorSequence")
        :Case("NumberSequence", function()
            local uuid = HttpService:GenerateGUID()
            frame.DataReferenceCache[uuid] = v
            serializedExtension[i] = `script.References[{uuid}]:GetAttribute("Value")`
        end)
        :End()
    end

    return frame
end

export type FunctionFrame = {
    Name: string,
    Extension: { [number]: any },
    Dependencies: { ModuleScript }?,
    DataReferenceCache: { [string]: any },
}

type Argument = Event.Argument

type FunctionWrapperProperties = {
    Name: string,
    DisplayName: string,
    Dependencies: { ModuleScript }?,
    Arguments: { Argument },
}

export type FunctionWrapper = FunctionWrapperProperties & {
    Extend: typeof(Extend)
}

--[=[
    Adds a FunctionWrapper to the list of wrappers in the Module

    @param properties The new properites for the wrapper
]=]
function Container.Add(properties: FunctionWrapperProperties)
    assert(properties.Name, string.format(ERROR_REQUIRED_PROPERTY_EMPTY, "Name"))
    assert(properties.DisplayName, string.format(ERROR_REQUIRED_PROPERTY_EMPTY, "DisplayName"))
    assert(properties.Arguments, string.format(ERROR_REQUIRED_PROPERTY_EMPTY, "Arguments"))
    assert(not Container[properties.Name], string.format(ERROR_WRAPPER_NAME_USED, properties.Name))

    local wrapper: FunctionWrapper = {
        Name = properties.Name,
        DisplayName = properties.DisplayName,
        Dependencies = properties.Dependencies,
        Arguments = properties.Arguments,
        Extend = Extend
    }

    Container.Wrappers[wrapper.Name] = wrapper
end

--[=[
    Loads all of the data from the Events into the Module.Wrappers map.
]=]
function Container.GenerateEvents()
    for _, v in script.Parent.Dependencies:GetChildren() do
        if not (v:IsA("ModuleScript")) then continue end
        local valueEvent: Event.Event = require(v)

        Container.Add {
            Name = v.Name,
            DisplayName = valueEvent.DisplayName,
            Dependencies = valueEvent.Dependencies,
            Arguments = valueEvent.Arguments
        }
    end
end

return Container