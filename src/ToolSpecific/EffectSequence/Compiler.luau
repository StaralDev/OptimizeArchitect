local Container = {}

local FunctionWrapper = require(script.Parent.FunctionWrapper)

export type CompileConfig = {
    FunctionFrames: { FunctionWrapper.FunctionFrame },
    Context: Enum.RunContext,
    Parent: Instance,
    SequenceLength: number,
}

local ERROR_ILLEGAL_CONTEXT = "Context \"%s\" is not allowed. Please restrict to use of Legacy and Client contexts."

local PREFIX = [[This sequence was compiled using Optimize Architect's EffectSequence tool.]]

local MIT_LICENSE = [[MIT License

Copyright (c) 2025 StaralDev

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.]]

-- You know god is dead when you're writing code in strings
local INITIATE_SINGLETON = [[local __SequenceSingleton = {
    Time = 0,
    SequenceLength = %s,
    Script = script,
    Parent = script.Parent,
    Garbage = {}
}]]

--[=[
    Adds a line to a string
    
    @param str The original string
    @param content The new line

    @return The string with a new line
]=]
local function AddLine(str: string, content: string?): string
    return str.."\n"..(content or "")
end

--[=[
    Adds blank lines to a string

    @param str The original string
    @param number The amount of blank lines to add

    @return The string with new blank lines
]=]
local function AddBlank(str: string, number: number): string
    for i = 1, number do
        str = AddLine(str)
    end
    return str
end

--[=[
    Returns all of the modules needed for dependancy reasons in
    the FunctionFrames provided.

    @param CompileConfig the singleton for compilation
    @return The collected modules
]=]
local function FindDependancyModules(CompileConfig: CompileConfig): { ModuleScript }
    local foundModules: { ModuleScript } = {}
    
    for _, v in CompileConfig.FunctionFrames do
        if (table.find(foundModules, v)) then continue end
        table.insert(foundModules, v)
    end

    return foundModules
end

--[=[
    Converts an array of strings into a single string, seperated by a comma
    like a list.

    @param arr The array to be converted
    @return A string of the array's elements
]=]
function UnpackArrayInString(arr: { [number]: string }) : string
    local returnString = ""
    for i, v in arr do
        returnString = returnString..v..if (i == #arr) then "" else ", "
    end
    return returnString
end

function Container.Compile(CompileConfig: CompileConfig)
    local SourceScript = Instance.new("Script")
    SourceScript.RunContext = CompileConfig.Context
    SourceScript.Parent = CompileConfig.Parent

    local Dependencies = Instance.new("Folder")
    Dependencies.Parent = SourceScript
    Dependencies.Name = "Dependencies"

    --[[
        Prefix, license and starting variables
    ]]
    local Source = PREFIX
    Source = AddBlank(Source, 2)
    Source = AddLine(Source, MIT_LICENSE)
    Source = AddBlank(Source, 2)

    Source = AddLine(Source, string.format(INITIATE_SINGLETON, CompileConfig.SequenceLength))
    Source = AddBlank(Source, 1)

    --[[
        Most of the functionality of each script runs once and is eventually
        garbage collected.
    ]]
    local dependancyModules = FindDependancyModules(CompileConfig)
    for _, v in dependancyModules do
        local dependancyCopy = v:Clone()
        dependancyCopy.Parent = Dependencies

        local nextLine = `local {v.Name} = require(script["Dependencies"]:FindFirstChild({v.Name}))`
        Source = AddLine(nextLine)
    end

    Source = AddBlank(Source, 1)

    for _, v in CompileConfig.FunctionFrames do
        local nextLine = `table.insert(__SequenceSingleton.Garbage, {v.Name}.Meta(__SequenceSingleton, {UnpackArrayInString(v.Extension)}))`
        Source = AddLine(Source, nextLine)
    end

    SourceScript.Source = Source
end