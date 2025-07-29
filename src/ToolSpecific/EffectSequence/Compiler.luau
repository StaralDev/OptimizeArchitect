local Container = {}

local FunctionWrapper = require(script.Parent.FunctionWrapper)

export type CompileConfig = {
    FunctionFrames: { FunctionWrapper.FunctionFrame },
    Context: Enum.RunContext,
    Parent: Instance,
    SequenceLength: number,
    SequenceSpeed: number,
}

local PREFIX = [[--!strict
-- This sequence was compiled using Optimize Architect's EffectSequence tool.
-- If you find any issues, bugs, or errors, please file a report at 'https://github.com/StaralDev/OptimizeArchitect/issues']]

local MIT_LICENSE = [=[--[[ MIT License

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
SOFTWARE.
]]]=]

local INITIATE_SINGLETON = [[local __SequenceSingleton = {
    Time = 0,
    SequenceLength = %s,
    SequenceSpeed = %s,
    Script = script,
    Parent = script.Parent,
    IsServer = IS_SERVER,
    Events = {},
}]]

local INITIATE_GET_SERVICES = [[local RunService = game:GetService("RunService")
local IS_SERVER = RunService:IsServer()]]
    
-- You know god is dead when you're writing code in strings
local AUTO_GET_CONTEXT_SIGNAL = [[local function GetContextSignal(): RBXScriptSignal
    return if (IS_SERVER) then 
        RunService.Heartbeat
    else
        RunService.RenderStepped
end]]

local AUTO_UPDATE = [[GetContextSignal():Connect(function(deltaTime)
    __SequenceSingleton.Time += deltaTime * __SequenceSingleton.SequenceSpeed
end)]]

--[=[
    Adds a line to a string
    
    @param str The original string
    @param content The new line

    @return The string with a new line
]=]
local function AddLine(str: string, content: string?): string
    local changed = str.."\n"..(content or "")
    return changed
end

--[=[
    Adds blank lines to a string

    @param str The original string
    @param number The amount of blank lines to add

    @return The string with new blank lines
]=]
local function AddBlank(str: string, number: number): string
    local changed = str
    for i = 1, number do
        changed = AddLine(changed)
    end
    return changed
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
        for _, dependency in (v.Dependencies) do
            if (table.find(foundModules, dependency)) then continue end
            table.insert(foundModules, dependency)
        end
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

    local EventModule = script.Parent.Event:Clone()
    EventModule.Parent = SourceScript

    local Dependencies = Instance.new("Folder")
    Dependencies.Parent = SourceScript
    Dependencies.Name = "Dependencies"

    --[[
        Prefix, license and starting variables
    ]]
    local Source = PREFIX
    Source = AddBlank(Source, 2)
    Source = AddLine(Source, MIT_LICENSE)
    print(Source)
    Source = AddBlank(Source, 2)
    print(Source)

    Source = AddLine(Source, INITIATE_GET_SERVICES)
    Source = AddBlank(Source, 1)
    Source = AddLine(Source, AUTO_GET_CONTEXT_SIGNAL)
    Source = AddBlank(Source, 1)
    Source = AddLine(Source, string.format(INITIATE_SINGLETON, CompileConfig.SequenceLength, CompileConfig.SequenceSpeed))
    Source = AddBlank(Source, 1)

    --[[
        Most of the functionality of each script runs once and is eventually
        garbage collected.
    ]]
    local dependancyModules = FindDependancyModules(CompileConfig)
    for _, v in dependancyModules do
        local dependancyCopy = v:Clone()
        dependancyCopy.Parent = Dependencies

        local nextLine = `local {v.Name} = require(script["Dependencies"]:FindFirstChild("{v.Name}"))`
        Source = AddLine(Source, nextLine)
    end

    Source = AddBlank(Source, 1)

    for _, v in CompileConfig.FunctionFrames do
        local nextLine = `{v.Name}:Fire(__SequenceSingleton, {UnpackArrayInString(v.Extension)})`
        Source = AddLine(Source, nextLine)
    end

    Source = AddBlank(Source, 1)

    --[[
        Update functionality
    ]]
    Source = AddLine(Source, AUTO_UPDATE)
    SourceScript.Source = Source

    return SourceScript
end

return Container