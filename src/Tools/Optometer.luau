local Tool = require(script.Parent.Parent.Menu.Tool)
local Types = require(script.Parent.Parent.Types)

local Util = require(script.Parent.Parent.Util)
local Config = require(script.Parent.Parent.Config)

local Selection = game:GetService("Selection")

local OptometerData = Config.Optometer.Data

local OptometerDial: ImageLabel

local function GetOptometerButtons(self: Tool.Tool): { TextButton }
    local nonMeter: { Types.StatisticData } = {}
    local buttons: { TextButton } = {}

    -- Create the Miscellanous button first before the other ones
    local miscButton: TextButton = self.Scope:ConstructTextButton {
        Colors = {
            BaseColor = Color3.new(0.321569, 0.380392, 0.572549),
            HoveredColor = Color3.new(0.384314, 0.447059, 0.647059),
            InteractedColor = Color3.new(0.270588, 0.325490, 0.478431),
            DisabledColor = Color3.new(0.458824, 0.494118, 0.600000)
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

        local optometerImage: ImageLabel = self.Scope:New "ImageLabel" {
            Image = "http://www.roblox.com/asset/?id=89620440286644",
            Size = UDim2.new(1, 0, 0.5, 0),
            BackgroundTransparency = 1,
            ZIndex = 80,
        }

        local optometerFront: ImageLabel = self.Scope:New "ImageLabel" {
            Image = "http://www.roblox.com/asset/?id=83138776989237",
            Size = UDim2.new(1, 0, 0.5, 0),
            BackgroundTransparency = 1,
            ZIndex = 100
        }

        OptometerDial = self.Scope:New "ImageLabel" {
            Image = "http://www.roblox.com/asset/?id=77442349647689",
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            ZIndex = 90,
            
            Rotation = 10,
        }

        local optometerSafeZone = self.Scope:New "ImageLabel" {
            Image = "http://www.roblox.com/asset/?id=120581916761815",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ImageColor3 = Color3.fromRGB(63, 79, 94),
            ZIndex = 10
        }

        local optometerWarningZone = self.Scope:New "ImageLabel" {
            Image = "http://www.roblox.com/asset/?id=120581916761815",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ImageColor3 = Color3.fromRGB(87, 79, 94),
            ZIndex = 11,

            Rotation = 80
        }

        local optometerDangerZone = self.Scope:New "ImageLabel" {
            Image = "http://www.roblox.com/asset/?id=120581916761815",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ImageColor3 = Color3.fromRGB(87, 52, 94),
            ZIndex = 12,

            Rotation = 120
        }

        local optometerCatastrophicZone = self.Scope:New "ImageLabel" {
            Image = "http://www.roblox.com/asset/?id=120581916761815",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ImageColor3 = Color3.fromRGB(54, 32, 63),
            ZIndex = 13,

            Rotation = 160
        }

        local optometerMaximumLable: TextLabel = self.Scope:PresetTextLabel() {
            Position = UDim2.new(1, 0, 0.5, 2),
            Size = UDim2.new(0.5, 0, 0, 12),
            AnchorPoint = Vector2.new(1, 0),
            Text = "8000",
            ZIndex = 110,
            TextColor3 = Color3.fromRGB(52, 58, 86),
            TextXAlignment = Enum.TextXAlignment.Right,
            TextYAlignment = Enum.TextYAlignment.Top
        }

        local optometerCurrentLabel: TextLabel = self.Scope:PresetTextLabel() {
            Position = UDim2.new(0, 0, 0.5, 14),
            Size = UDim2.new(1, 0, 0.5, -38),
            Text = "1000",
            ZIndex = 115,
            TextScaled = true
        }

        local optometerOptimizationLabel: TextLabel = self.Scope:PresetTextLabel() {
            Position = UDim2.new(0, 0, 1, 0),
            AnchorPoint = Vector2.new(0, 1),
            Size = UDim2.new(1, 0, 0, 20),
            Text = "SAFE",
            ZIndex = 115,
            TextScaled = true
        }

        local optometerFrame: Frame = self.Scope:New "Frame" {
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, 0, 0, 26),
            Size = UDim2.new(0.6, 0, 1, 0),
            AnchorPoint = Vector2.new(0.5, 0),
            ClipsDescendants = false,
            
            [self.Scope.Children] = {
                self.Scope:New "UIAspectRatioConstraint" {
                    AspectRatio = 1,
                    DominantAxis = Enum.DominantAxis.Width
                },
                optometerImage,
                OptometerDial,
                optometerFront,

                self.Scope:New "ImageLabel" {
                    Image = "http://www.roblox.com/asset/?id=120581916761815",
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    ImageColor3 = Color3.fromRGB(59, 54, 85)
                },

                self.Scope:New "Frame" {
                    BackgroundColor3 = Color3.fromRGB(37, 40, 58),
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                    AnchorPoint = Vector2.new(0.5, 0),
                    Size = UDim2.new(1, 10, 0.5, 10),
                    ZIndex = 101,
                },

                self.Scope:PresetTextLabel() {
                    Position = UDim2.new(0, 0, 0.5, 2),
                    Size = UDim2.new(0.5, 0, 0, 12),
                    AnchorPoint = Vector2.new(0, 0),
                    Text = "0",
                    ZIndex = 110,
                    TextColor3 = Color3.fromRGB(52, 58, 86),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Top
                },

                optometerMaximumLable,
                optometerCurrentLabel,
                optometerOptimizationLabel,

                optometerSafeZone,
                optometerWarningZone,
                optometerDangerZone,
                optometerCatastrophicZone,
            }
        }

        local meterLayoutFrame: Frame = self.Scope:New "Frame" {
            BackgroundTransparency = 0,
            Position = UDim2.new(0, 0, 0, 54),
            Size = UDim2.new(1, 0, 1, -54),
            ClipsDescendants = true,
            BackgroundColor3 = Color3.fromRGB(37, 40, 58),

            [self.Scope.Children] = {
                self.Scope:New "UIPadding" {
                    PaddingBottom = UDim.new(0, 6),
                    PaddingLeft = UDim.new(0, 6),
                    PaddingRight = UDim.new(0, 6),
                    PaddingTop = UDim.new(0, 6),
                },
                self.Scope:New "UICorner" {
                    CornerRadius = UDim.new(0, 6),
                },

                optometerFrame,
                
                self.Scope:PresetTextLabel() {
                    Position = UDim2.new(0.5, 0, 0, 0),
                    AnchorPoint = Vector2.new(0.5, 0),
                    Size = UDim2.new(1, 0, 0, 20),
                    TextScaled = true,
                    Text = "Particles on Average per Emit"
                }
            }
        }

        meterLayoutFrame.Parent = self.MenuFrame
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

    OnTick = function(self: Tool.Tool, deltaTime: number)
        OptometerDial.Rotation += 70 * deltaTime
    end
}

return Optometer