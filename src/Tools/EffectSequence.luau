local Tool = require(script.Parent.Parent.Menu.Tool)
local Types = require(script.Parent.Parent.Types)
local Fusion = require(script.Parent.Parent.Packages.Fusion)

local Util = require(script.Parent.Parent.Util)
local Config = require(script.Parent.Parent.Config)

local ToolSpecific = script.Parent.Parent.ToolSpecific.EffectSequence
local Compiler = require(ToolSpecific.Compiler)
local FunctionWrapper = require(ToolSpecific.FunctionWrapper)

local EffectSequence = Tool.new {
    Title = "Effect Sequence",
    Description = "Automatically creates a script made of different selectable events.",
    Enabled = true,

    Opened = function(self: Tool.Tool)
        FunctionWrapper.GenerateEvents()

        local compileButton = self.Scope:ConstructTextButton {} {
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0.5, 0, 0.2, 0),
            Text = "Test compile",

            [self.Scope.OnEvent("MouseButton1Click")] = function()
                print(FunctionWrapper.Wrappers)

                local TestFrames = {
                    FunctionWrapper.Wrappers["ColorEvent"]:Extend({"\"Bluh\""})
                }
                
                local compiledScript = Compiler.Compile({
                    FunctionFrames = TestFrames,
                    Context = Enum.RunContext.Server,
                    Parent = workspace,
                    SequenceLength = 4,
                    SequenceSpeed = 2
                })

                print("Attempted compile!", compiledScript)
            end
        }

        compileButton.Parent = self.MenuFrame
    end,
}

return EffectSequence