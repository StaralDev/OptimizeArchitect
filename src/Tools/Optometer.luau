local Tool = require(script.Parent.Parent.Menu.Tool)
local Types = require(script.Parent.Parent.Types)

local Util = require(script.Parent.Parent.Util)
local Config = require(script.Parent.Parent.Config)

local Selection = game:GetService("Selection")

local OptometerData: Types.Statistics<Types.StatisticData> = {
    Instances = {
        High = 500,
        Dangerous = 1000,
        Cataclysmic = 2000,
        Max = 2500,

        DisplayName = "Instances",
        UseMeter = true
    },

    Parts = {
        High = 150,
        Dangerous = 300,
        Cataclysmic = 1000,
        Max = 1150,

        DisplayName = "Parts",
        UseMeter = true,
    },

    Beams = {
        DisplayName = "Beams",
        UseMeter = false
    },

    EnabledBeams = {
        DisplayName = "Enabled Beams",
        UseMeter = false
    },

    BeamSegments = {
        High = 2000,
        Dangerous = 4000,
        Cataclysmic = 8000,
        Max = 10000,

        DisplayName = "Beam Segments",
        UseMeter = true
    },

    Constraints = {
        DisplayName = "Constraints",
        UseMeter = false
    },

    Attachments = {
        DisplayName = "Attachments",
        UseMeter = false
    },

    Motors = {
        DisplayName = "Motor6Ds",
        UseMeter = false
    },

    ParticleEmitters = {
        DisplayName = "ParticleEmitters",
        UseMeter = false
    },

    EnabledEmitters = {
        DisplayName = "Enabled ParticleEmitters",
        UseMeter = false
    },

    ParticlesOnAverage = {
        High = 4000,
        Dangerous = 8000,
        Cataclysmic = 16000,
        Max = 16500,

        DisplayName = "Particles On Average",
        ShortName = "Particles/avg",
        UseMeter = true
    },

    ParticleMass = {
        Max = 10000,
        DisplayName = "Particle Mass",
        UseMeter = true
    }
}

local function GetOptometerButtons(self: Tool.Tool): { TextButton }
    local nonMeter: { Types.StatisticData } = {}
    local buttons: { TextButton } = {}

    -- Create the Miscellanous button first before the other ones
    local miscButton: TextButton = self.Scope:ConstructTextButton {
        Colors = {
            BaseColor = Color3.new(0.305882, 0.368627, 0.572549),
            HoveredColor = Color3.new(0.368627, 0.431373, 0.647059),
            InteractedColor = Color3.new(0.262745, 0.321569, 0.494118),
            DisabledColor = Color3.new(0.427451, 0.466667, 0.588235)
        }
    } {
        Text = "Miscellaneous",
        Size = UDim2.new(0, 120, 1, -2),
        TextSize = 10
    }

    table.insert(buttons, miscButton)

    for i, v in OptometerData do
        if (v.UseMeter) then
            
            local catagoryButton: TextButton = self.Scope:ConstructTextButton {} {
                Text = v.ShortName or v.DisplayName,
                Size = UDim2.new(0, 120, 1, -2),
                TextSize = 10
            }

            table.insert(buttons, catagoryButton)

        else
            nonMeter[i] = v
        end
    end

    return buttons
end

local selectedConnection: RBXScriptConnection?

local Optometer = Tool.new { 
    Enabled = true, 
    Title = "Opto-Meter",
    Description = "See how well you optimized your VFX.",

    Opened = function(self: Tool.Tool)
        local optometerButtons = GetOptometerButtons(self)

        local padding = self.Scope:New "UIPadding" {
            PaddingBottom = UDim.new(0, 6),
            PaddingLeft = UDim.new(0, 6),
            PaddingRight = UDim.new(0, 6),
            PaddingTop = UDim.new(0, 6),
        }

        local checkSelectedButton: TextButton = self.Scope:ConstructTextButton {} {
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 0, 24),
            Text = "Check Selected",
            TextScaled = true,
        }
        checkSelectedButton.FontFace.Bold = true

        local optionFrame: ScrollingFrame = self.Scope:New "ScrollingFrame" {
            Position = UDim2.new(0, 0, 0, 30),
            Size = UDim2.new(1, 0, 0, 18),
            ScrollBarThickness = Config.Menu.ScrollbarThickness,
            HorizontalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
            VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Left,
            ScrollBarImageTransparency = 0,
            ScrollBarImageColor3 = Config.Colors.ScrollBar,
            CanvasSize = UDim2.new(0, 126 * #optometerButtons, 0, 0),
            BackgroundTransparency = 0,
            BackgroundColor3 = Config.Colors.Holder,

            [self.Scope.Children] = {
                self.Scope:New "UIListLayout" {
                    FillDirection = Enum.FillDirection.Horizontal,
                    Padding = UDim.new(0, 6)
                },
                optometerButtons
            }
        }

        padding.Parent = self.MenuFrame
        checkSelectedButton.Parent = self.MenuFrame
        optionFrame.Parent = self.MenuFrame
    end,

    Closed = function(self: Tool.Tool)
        if (selectedConnection) then
            selectedConnection:Disconnect()
            selectedConnection = nil
        end
    end,
}

return Optometer