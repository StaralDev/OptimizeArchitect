local Tool = require(script.Parent.Parent.Menu.Tool)
local Types = require(script.Parent.Parent.Types)
local Fusion = require(script.Parent.Parent.Packages.Fusion)
local Dynamics = require(script.Parent.Parent.Packages.Dynamics)

local Util = require(script.Parent.Parent.Util)
local Config = require(script.Parent.Parent.Config)

local Selection = game:GetService("Selection")

local CurrentTab: Fusion.Value<string>

local DeltaCounter = 0

local OptometerDial: ImageLabel
local OptometerFrame: Frame
local MeterLayoutFrame: Frame

local OptometerData = Config.Optometer.Data

local CurrentData: Fusion.Value<Types.Statistics<number>>
local LastSelection: {Instance}

local CounterDynamics = Dynamics.new(1.3, 0.5, 1.5, 0)
local LabelDynamics = Dynamics.new(1, 1, 0, 0)

local OptometerCurrentLabel: TextLabel
local OptometerOptimizationLabel: TextLabel

local OptometerTopText: TextLabel

--[=[
    Uses sin() multiplication to calculate how much
    the dial should be shaken.

    @param alpha The time that should be given to the function
    @return The interpolated value of the function
]=]
local function CalculateDialShake(alpha): number
    -- https://www.desmos.com/calculator/e1awij5xnf
    return math.abs(
        math.sin(5*alpha) 
        * math.sin(0.8 * alpha)
        * (3 * math.sin(1.3 * alpha))
        * math.sin(8 * alpha)
        * math.sin(20 * alpha)
    )
end

local function GetDialZone(current: number, high: number?, dangerous: number?, cataclysmic: number?): "Safe" | "High" | "Dangerous" | "Cataclysmic"
    if (cataclysmic and current >= cataclysmic) then return "Cataclysmic" end
    if (dangerous and current >= dangerous) then return "Dangerous" end
    if (high and current >= high) then return "High" end
    return "Safe"
end

--[=[
    Returns one of 4 paramaters depending on if the Current number is within that zone on the dial.

    @param current The number to be tested
    @param data The data about this Statistic
    @param onSafe The param to be selected if the current number is safe
    @param onHigh The param to be selected if the current number is high
    @param onDangerous The param to be selected if the current number is dangerous
    @param onCataclysmic The param to be selected if the current number is cataclysmic

    @return The param coresponding to the place on the dial
]=]
local function ChooseFromDialZone<T>(current: number, data: Types.StatisticData, onSafe: T, onHigh: T, onDangerous: T, onCataclysmic: T): T
    local dialZone = GetDialZone(current, data.High, data.Dangerous, data.Cataclysmic)
    if (dialZone == "Safe") then return onSafe end
    if (dialZone == "High") then return onHigh end
    if (dialZone == "Dangerous") then return onDangerous end
    if (dialZone == "Cataclysmic") then return onCataclysmic end

    return onSafe
end

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
        TextSize = 10,
        LayoutOrder = 1000,

        [self.Scope.OnEvent("MouseButton1Click")] = function()
            CurrentTab:set("Miscellaneous")
        end
    }

    table.insert(buttons, miscButton)

    for i, v: Types.StatisticData in OptometerData do
        if (v.UseMeter) then
            
            local catagoryButton: TextButton = self.Scope:ConstructTextButton {} {
                Text = v.ShortName or v.DisplayName,
                Size = UDim2.new(0, 120, 1, -2),
                TextSize = 10,
                LayoutOrder = 0 - (v.ButtonPriority or 0),
                [self.Scope.OnEvent("MouseButton1Click")] = function()
                    CurrentTab:set(i)
                end
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
        -- The initialvalue of the FusionValue is just to have starting stats that don't mean anything
        CurrentData = self.Scope:Value(Util.GetStatistics({}))
        CurrentTab = self.Scope:Value("ParticlesOnAverage")

        local optometerButtons = GetOptometerButtons(self)

        local padding = self.Scope:New "UIPadding" {
            PaddingBottom = UDim.new(0, 6),
            PaddingLeft = UDim.new(0, 6),
            PaddingRight = UDim.new(0, 6),
            PaddingTop = UDim.new(0, 6),
        }

        local refreshSelectionButton: ImageButton = self.Scope:ConstructImageButton {
            PropertyToChange = "BackgroundColor3",
            Corner = UDim.new(0, 6)
        } {
            Image = "rbxassetid://86084882582277",
            Position = UDim2.new(1, 0, 0, 0),
            AnchorPoint = Vector2.new(1, 0),
            Size = UDim2.new(0, 28, 0, 28),
            ZIndex = 3,

            [self.Scope.OnEvent("MouseButton1Click")] = function()
                if not (LastSelection) then return end
                local collectedInstances = {}

                for _, parent in LastSelection do
                    table.insert(collectedInstances, parent)
                    for _, descendant in parent:GetDescendants() do
                        table.insert(collectedInstances, descendant)
                    end
                end

                CurrentData:set(Util.GetStatistics(collectedInstances))
            end
        }

        local checkSelectedButton: TextButton = self.Scope:ConstructTextButton {} {
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, -28 - 6, 0, 28),
            Text = "Check Selected",
            TextScaled = true,

            [self.Scope.OnEvent("MouseButton1Click")] = function()
                local parentInstances: {Instance} = Selection:Get()
                LastSelection = parentInstances

                local collectedInstances = {}

                for _, parent in parentInstances do
                    table.insert(collectedInstances, parent)
                    for _, descendant in parent:GetDescendants() do
                        table.insert(collectedInstances, descendant)
                    end
                end

                CurrentData:set(Util.GetStatistics(collectedInstances))
            end
        }
        checkSelectedButton.FontFace.Bold = true

        local optionFrame: ScrollingFrame = self.Scope:New "ScrollingFrame" {
            Position = UDim2.new(0, 0, 0, 34),
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
                    Padding = UDim.new(0, 6),
                    SortOrder = Enum.SortOrder.LayoutOrder
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

        local optometerSafeZone: ImageLabel = self.Scope:New "ImageLabel" {
            Image = "http://www.roblox.com/asset/?id=120581916761815",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ImageColor3 = Color3.fromRGB(63, 79, 94),
            ZIndex = 10
        }

        local optometerWarningZone: ImageLabel = self.Scope:New "ImageLabel" {
            Image = "http://www.roblox.com/asset/?id=120581916761815",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ImageColor3 = Color3.fromRGB(87, 79, 94),
            ZIndex = 11,

            Rotation = 80
        }

        local optometerDangerZone: ImageLabel = self.Scope:New "ImageLabel" {
            Image = "http://www.roblox.com/asset/?id=120581916761815",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ImageColor3 = Color3.fromRGB(87, 52, 94),
            ZIndex = 12,

            Rotation = 120
        }

        local optometerCatastrophicZone: ImageLabel = self.Scope:New "ImageLabel" {
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

        OptometerCurrentLabel = self.Scope:PresetTextLabel() {
            Position = UDim2.new(0, 0, 0, 6),
            Size = UDim2.new(1, 0, 1, -28),
            Text = "1000",
            ZIndex = 115,
            TextScaled = true,
            Font = Enum.Font.GothamBold,
            [self.Scope.Children] = {
                self.Scope:New "UIStroke" {
                    Color = Color3.fromRGB(30, 23, 62),
                    Thickness = 2
                }
            }
        }

        OptometerOptimizationLabel = self.Scope:PresetTextLabel() {
            Position = UDim2.new(0, 0, 1, 0),
            AnchorPoint = Vector2.new(0, 1),
            Size = UDim2.new(1, 0, 0, 32),
            Text = "SAFE",
            Font = Enum.Font.GothamBlack,
            ZIndex = 115,
            TextScaled = true,
            
            [self.Scope.Children] = {
                self.Scope:New "UIStroke" {
                    Color = Color3.fromRGB(30, 23, 62),
                    Thickness = 2
                }
            }
        }

        OptometerFrame = self.Scope:New "Frame" {
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, 0, 0, 26),
            Size = UDim2.new(1, 0, 1, -20),
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

                optometerSafeZone,
                optometerWarningZone,
                optometerDangerZone,
                optometerCatastrophicZone,
            }
        }

        local labelFrame: Frame = self.Scope:New "Frame" {
            Position = UDim2.new(0.5, 0, 1, -6),
            Size = UDim2.new(1, -12, 0.4, -16),
            AnchorPoint = Vector2.new(0.5, 1),
            ZIndex = 150,
            BackgroundTransparency = 1,

            [self.Scope.Children] = {
                OptometerCurrentLabel,
                OptometerOptimizationLabel
            }
        }

        OptometerTopText = self.Scope:PresetTextLabel() {
            Position = UDim2.new(0.5, 0, 0, 0),
            AnchorPoint = Vector2.new(0.5, 0),
            Size = UDim2.new(1, 0, 0, 20),
            TextScaled = true,
            Text = "Particles On Average"
        }

        MeterLayoutFrame = self.Scope:New "Frame" {
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

                OptometerFrame,
                OptometerTopText
            }
        }

        local GeneralDetailTopbar: TextLabel = self.Scope:PresetTextLabel() {
            Position = UDim2.new(0.5, 0, 0, 54),
            AnchorPoint = Vector2.new(0.5, 0),
            Size = UDim2.new(1, 0, 0, 20),
            TextScaled = true,
            Text = "Miscellaneous"
        }

        local GeneralDetailFrame: ScrollingFrame = self.Scope:New "ScrollingFrame" {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, -20 - 54 - 6),
            Position = UDim2.new(0, 0, 0, 20 + 54 + 6),
            ScrollBarImageTransparency = 0,
            ScrollBarImageColor3 = Config.Colors.ScrollBar,
            ScrollBarThickness = Config.Menu.ScrollbarThickness,
            HorizontalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
            VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right,

            [self.Scope.Children] = {
                self.Scope:New "UIListLayout" {
                    FillDirection = Enum.FillDirection.Vertical,
                    Padding = UDim.new(0, 6),
                    SortOrder = Enum.SortOrder.LayoutOrder
                },
            }
        }

        local function DataUpdated()
            local tab = self.Scope.peek(CurrentTab)
            local data = self.Scope.peek(CurrentData)

            if (tab ~= "Miscellaneous") then
                local currentConfig: Types.StatisticData = OptometerData[tab]
                local text = if (currentConfig.ShowHighestWarningAsMax) then 
                    currentConfig.Cataclysmic 
                    or currentConfig.Dangerous 
                    or currentConfig.High 
                    or currentConfig.Max
                else
                    currentConfig.Max

                optometerMaximumLable.Text = text or 0
                OptometerTopText.Text = currentConfig.DisplayName
                
                if (currentConfig.Max) then
                    optometerWarningZone.Rotation = ((if (currentConfig.High) then currentConfig.High/currentConfig.Max else 1) * 180)
                    optometerDangerZone.Rotation = ((if (currentConfig.Dangerous) then currentConfig.Dangerous/currentConfig.Max else 1) * 180)
                    optometerCatastrophicZone.Rotation = ((if (currentConfig.Cataclysmic) then currentConfig.Cataclysmic/currentConfig.Max else 1) * 180)
                end

                optometerSafeZone.Visible = (currentConfig.High or currentConfig.Dangerous or currentConfig.Cataclysmic) ~= nil
            else
                for _, v in GeneralDetailFrame:GetChildren() do
                    if (v:IsA("Frame")) then
                        v:Destroy()
                    end
                end

                local order = 0
                for i, v: Types.StatisticData in OptometerData do
                    order += 1
                    local currentStat = math.clamp(math.round((data[i] or 0) * 100) / 100, 0, 10e8)
                    local stringifiedStat = if (currentStat or 0 > 10e8) then tostring(currentStat) else "Infinity"

                    local amountTextColor = ChooseFromDialZone(currentStat, v, 
                        Color3.new(1, 1, 1), 
                        Color3.new(1, 1, 0), 
                        Color3.new(1, 0, 0), 
                        Color3.new(0.65, 0, 0)
                    )
                    local nameTextColor = Util.ModifyHSV(amountTextColor, 0, 0, -0.15)
                    local isCataclysmic = GetDialZone(currentStat, v.High, v.Dangerous, v.Cataclysmic) ~= "Safe"

                    local strokeStart = if (isCataclysmic) then
                        `<stroke color="#000000">`
                    else
                        ""

                    local strokeEnd = if (isCataclysmic) then
                        `</stroke>`
                    else
                        ""

                    local statFrame: Frame = self.Scope:New "Frame" {
                        Size = UDim2.new(1, -6, 0, 18),
                        BackgroundColor3 = ChooseFromDialZone(currentStat, v,
                            Color3.fromHSV(0.642857, 0.362069, 0.227451),
                            Color3.fromRGB(87, 79, 94),
                            Color3.fromRGB(87, 52, 94),
                            Color3.fromRGB(54, 32, 63)
                        ),
                        LayoutOrder = v.ManualOrder or order,

                        [self.Scope.Children] = {

                            self.Scope:New "UICorner" {
                                CornerRadius = UDim.new(0, 6),
                            },

                            self.Scope:PresetTextLabel() {
                                BackgroundTransparency = 1,
                                TextSize = 14,
                                RichText = true,
                                TextXAlignment = Enum.TextXAlignment.Left,
                                Text = `  {strokeStart}<font color="#{nameTextColor:ToHex()}">{v.ShortName or v.DisplayName or i}:</font> <font color="#{amountTextColor:ToHex()}">{stringifiedStat}</font>{strokeEnd}`,
                                Size = UDim2.new(1, 0, 1, -2),
                                Position = UDim2.new(0, 0, 0, 1)
                            }
                        }
                    }

                    statFrame.Parent = GeneralDetailFrame
                end

                GeneralDetailFrame.CanvasSize = UDim2.new(0, 0, 0, order * 24)
            end

            local tabMiscellaneous = (tab == "Miscellaneous")

            MeterLayoutFrame.Visible = not tabMiscellaneous
            labelFrame.Visible = not tabMiscellaneous

            GeneralDetailFrame.Visible = tabMiscellaneous
            GeneralDetailTopbar.Visible = tabMiscellaneous
        end

        self.Scope:Observer(CurrentTab):onChange(DataUpdated)
        self.Scope:Observer(CurrentData):onChange(DataUpdated)

        GeneralDetailFrame.Parent = self.MenuFrame
        GeneralDetailTopbar.Parent = self.MenuFrame

        MeterLayoutFrame.Parent = self.MenuFrame
        labelFrame.Parent = self.MenuFrame
        
        checkSelectedButton.Parent = self.MenuFrame
        refreshSelectionButton.Parent = self.MenuFrame
        optionFrame.Parent = self.MenuFrame
        padding.Parent = self.MenuFrame

        DataUpdated()
    end,

    Closed = function(self: Tool.Tool)
        if (selectedConnection) then
            selectedConnection:Disconnect()
            selectedConnection = nil
        end
    end,

    OnTick = function(self: Tool.Tool, deltaTime: number)
        DeltaCounter += deltaTime

        local tab = self.Scope.peek(CurrentTab)

        if (tab ~= "Miscellaneous") then
            local currentStatisticsAmount: number = self.Scope.peek(CurrentData)[tab] or 0
            local currentConfig: Types.StatisticData = OptometerData[tab]

            assert(currentConfig and tab, "Tab is invalid")

            -- math.max makes sure the number never becomes negative 0
            local optometerDialMovement = math.max(CounterDynamics:Update(deltaTime, (math.clamp(currentStatisticsAmount or 0, 0, 10e8)/(currentConfig.Max or 1))), 0)
            local optometerDisplayMovement = math.max(LabelDynamics:Update(deltaTime, math.clamp(currentStatisticsAmount or 0, 0, 10e8)), 0)

            local dialAlpha = math.clamp(optometerDialMovement, 0, 1)
            local dialOffset = -3 * CalculateDialShake(DeltaCounter * 0.6)

            OptometerDial.Rotation = ((dialAlpha * 180) - 90) + (dialOffset * math.pow(dialAlpha, 2))
            
            OptometerCurrentLabel.Text = if ((math.round(optometerDisplayMovement)) < 10e8) then 
                tostring(math.round(optometerDisplayMovement)) 
            else
                -- Tiny easter egg for anyone stupid enough 
                "Infinity"

            local dialZone = GetDialZone(currentStatisticsAmount, currentConfig.High, currentConfig.Dangerous, currentConfig.Cataclysmic)
            OptometerOptimizationLabel.Text = dialZone:upper()
            
            local dangerColor = Color3.new(1, 1, 1)

            if (dialZone == "High") then
                dangerColor = Color3.new(1, 1, 0)
            elseif (dialZone == "Dangerous") then
                dangerColor = Color3.new(1, 0, 0)
            elseif (dialZone == "Cataclysmic") then
                dangerColor = Color3.new(0.3, 0, 0)
            end

            OptometerOptimizationLabel.TextColor3 = dangerColor
            OptometerCurrentLabel.TextColor3 = dangerColor

        end

        OptometerFrame.Size = UDim2.new(1, 0, 0, MeterLayoutFrame.AbsoluteSize.Y - 38 - 12)
    end
}

return Optometer