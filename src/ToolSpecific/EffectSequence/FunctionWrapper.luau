local Container = {}
Container.Wrappers = {} :: { [string]: FunctionWrapper }

local ERROR_WRAPPER_NAME_USED = "Wrapper name \"%s\" is already in use!"
local ERROR_REQUIRED_PROPERTY_EMPTY = "Required property \"%s\" is nil or empty!"

--[=[
    Creates a FunctionFrame for a given wrapper.

    @param self The FunctionWrapper to be used
    @param extension The paramaters of the function

    @return A new FunctionFrame with the provided paramaters
]=]
local function Extend(self: FunctionWrapper, extension: { [number]: any }): FunctionFrame
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

export type FunctionWrapperProperties = {
    Name: string,
    DisplayName: string,
    Dependancies: { ModuleScript }?,
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
    assert(not Container[properties.Name], string.format(ERROR_WRAPPER_NAME_USED, properties.Name))
    
    local wrapper: FunctionWrapper = {
        Name = properties.Name,
        DisplayName = properties.DisplayName,
        Dependancies = properties.Dependancies,
        Extend = Extend
    }

    Container[wrapper.Name] = wrapper
end

return Container