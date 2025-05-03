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

    local frame: FunctionFrame = {
        Name = self.Name,
        Extension = extension,
        Dependancies = self.Dependancies
    }

    return frame
end

export type FunctionFrame = {
    Name: string,
    Extension: { [number]: any },
    Dependancies: { ModuleScript }?
}

export type Argument = {
    Name: string,
    Type: string
}

type FunctionWrapperProperties = {
    Name: string,
    DisplayName: string,
    Dependancies: { ModuleScript }?,
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
        Dependancies = properties.Dependancies,
        Arguments = properties.Arguments,
        Extend = Extend
    }

    Container[wrapper.Name] = wrapper
end

return Container