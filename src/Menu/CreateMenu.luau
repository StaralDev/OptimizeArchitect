local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

local Config = require(script.Parent.Parent.Config)
local Tool = require(script.Parent.Tool)
local Util = require(script.Parent.Parent.Util)
local Types = require(script.Parent.Parent.Types)

local MenuScope = require(script.Parent.GetMenuScope)()
local CurrentTool: Tool.Tool? = nil

local SplashImage: ImageLabel

local function GenerateTools(): { Tool.Tool }
    local tools: { Tool.Tool } = {}

    for _, v: ModuleScript in script.Parent.Parent.Tools:GetChildren() do
        local tool: Tool.Tool = require(v)
        table.insert(tools, tool)
    end

    return tools
end

local function GenerateButtons(tools: { Tool.Tool }): { TextButton }
    local buttons: { TextButton } = {}
    local texts: { string } = {}

    for _, tool in tools do
        local newButton: TextButton
        
        assert(not table.find(texts, tool.Title), "Duplicate tool titles found")
        table.insert(texts, tool.Title)

        newButton = MenuScope:ConstructTextToggle { 
            Enabled = false,
            OnEnabled = function()

                if (SplashImage) then
                    SplashImage.Visible = false
                end

                for _, v in buttons do
                    if (v == newButton) then continue end
                    v:SetAttribute("Enabled", false)
                end

                if (CurrentTool) then
                    if (CurrentTool.Cleanup) then
                        for _, v in CurrentTool.Cleanup do
                            v:Disconnect()
                        end
                    end
                    
                    if (CurrentTool.Closed) then CurrentTool.Closed(CurrentTool) end
                    CurrentTool.Scope:doCleanup()
                    CurrentTool:RegenerateScope()
                end

                CurrentTool = tool
                if (tool.Opened) then tool.Opened(tool) end
            end,
            OnDisabled = function()
                if not (CurrentTool) then return end
                if (newButton.Text == CurrentTool.Title) then
                    if (SplashImage) then
                        SplashImage.Visible = true
                    end

                    if (CurrentTool.Closed) then CurrentTool.Closed(CurrentTool) end
                    CurrentTool.Scope:doCleanup()
                    CurrentTool:RegenerateScope()
                end
            end,
            ToggledColors = Config.Components.SelectedButtonColor,
            UntoggledColors = Config.Components.DefaultButtonColor
        } { 
            Text = tool.Title,
            Size = UDim2.new(1, 0, 0, Config.Menu.ButtonSize),
            TextSize = Config.Menu.ButtonTextSize
        }

        table.insert(buttons, newButton)
    end

    return buttons
end

local function CreateMenu(plugin: Plugin, widget: DockWidgetPluginGui)

    local Runloop: RBXScriptConnection

    local Children = MenuScope.Children
    local SidebarOpened = MenuScope:Value(true)

    local splashColor = Util.ModifyHSV(Config.Colors.Background, 0, 0, -0.05)

    SplashImage = MenuScope:New "ImageLabel" {
        Image = "http://www.roblox.com/asset/?id=128863203048866",
        BackgroundTransparency = 1,
        ImageTransparency = 0.75,
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ImageColor3 = splashColor,
        [Children] = {
            MenuScope:New "UIAspectRatioConstraint" {},
        }
    }
    
    -- The holder that contains the selected tool.
    local Holder: Frame = MenuScope:New "Frame" {
        Name = "Holder",
        BackgroundColor3 = Config.Colors.Holder,
        [Children] = {
            MenuScope:New "UICorner" {
                CornerRadius = Config.Menu.CornerRadius
            },
            SplashImage
        },
        Size = UDim2.new(1, -Config.Menu.SidebarWidth-Config.Menu.ArrowPadding, 1, 0),
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 0)
    }
    Tool.SetMenuFrame(Holder)
    
    local Tools = GenerateTools()
    local Buttons = GenerateButtons(Tools)

    local ScrollingPadding: UIPadding = MenuScope:New "UIPadding"
    {
        PaddingTop = UDim.new(0, Config.Menu.ToolButtonPadding),
    }

    local ScrollingFrame: ScrollingFrame = MenuScope:New "ScrollingFrame" {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Left,
        ScrollBarThickness = Config.Menu.ScrollbarThickness,
        VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
        ScrollBarImageTransparency = 0,
        ScrollBarImageColor3 = Config.Colors.ScrollBar,
        CanvasSize = UDim2.new(0, 0, 0, #Buttons + (Config.Menu.ToolButtonPadding * #Buttons)),

        [Children] = {
            MenuScope:New "UIListLayout" {
                Padding = UDim.new(0, Config.Menu.ToolButtonPadding)
            },
            ScrollingPadding,
            Buttons
        }
    }

    local Arrow: ImageButton
    
    Arrow = MenuScope:ConstructImageButton {
        DontChangeColor = true
    } {
        BackgroundTransparency = 1,
        Image = "http://www.roblox.com/asset/?id=8317995440",
        Position = UDim2.new(0, Config.Menu.SidebarWidth + Config.Menu.ToolButtonPadding, 0.5, 0),
        Size = UDim2.new(0, Config.Menu.ArrowPadding - Config.Menu.ToolButtonPadding * 2, 0, 120),
        Rotation = 180,
        AnchorPoint = Vector2.new(0, 0.5),
        ZIndex = 20,
        ImageColor3 = Util.ModifyHSV(Config.Colors.Background, 0, 5/255, 15/255),
        [MenuScope.OnEvent("MouseButton1Click")] = function()
            SidebarOpened:set(not MenuScope.peek(SidebarOpened))

            local opened = MenuScope.peek(SidebarOpened)

            if (opened) then
                Util.TweenButton(
                    Arrow, 
                    Config.Components.DefaultTransition, 
                    Util.ModifyHSV(Config.Colors.Background, 0, 5/255, 15/255),
                    "ImageColor3"
                ):Play()
            else
                Util.TweenButton(
                    Arrow, 
                    Config.Components.DefaultTransition, 
                    Util.ModifyHSV(Config.Colors.Background, 0, 7/255, 25/255),
                    "ImageColor3"
                ):Play()
            end
        end
    };

    -- The sidebar where you can select a button to open a tool.
    local Sidebar: Frame = MenuScope:New "Frame" {
        Name = "Sidebar",
        BackgroundColor3 = Config.Colors.Sidebar,
        [Children] = {
            MenuScope:New "UICorner" {
                CornerRadius = Config.Menu.CornerRadius
            },

            MenuScope:New "UIPadding" {
                PaddingLeft = UDim.new(0, Config.Menu.ToolButtonPadding),
                PaddingRight = UDim.new(0, Config.Menu.ToolButtonPadding)
            },

            ScrollingFrame,
        },
        Size = UDim2.new(0, Config.Menu.SidebarWidth, 1, 0),
    }

    -- The frame that has everything inside it.
    local MenuFrame: Frame = MenuScope:New "Frame" {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Config.Colors.Background,
        [Children] = {
            MenuScope:New "UIPadding" {
                PaddingBottom = Config.Menu.MainPadding,
                PaddingLeft = Config.Menu.MainPadding,
                PaddingRight = Config.Menu.MainPadding,
                PaddingTop = Config.Menu.MainPadding
            },

            Sidebar,
            Holder,
            Arrow
        }
    }
    MenuFrame.Parent = widget

    local sidebarOpenedObserver = MenuScope:Observer(SidebarOpened)
    sidebarOpenedObserver:onChange(function()
        
        local sidebarIsOpened = MenuScope.peek(SidebarOpened)
        Holder.Size = if (sidebarIsOpened) then 
            UDim2.new(1, -Config.Menu.SidebarWidth-Config.Menu.ArrowPadding, 1, 0) 
        else 
            UDim2.new(1, -Config.Menu.ArrowPadding, 1, 0) 

        Arrow.Position = UDim2.new(0, if (sidebarIsOpened) then 
            Config.Menu.SidebarWidth + Config.Menu.ToolButtonPadding
        else
            Config.Menu.ToolButtonPadding, 0.5, 0)

        Sidebar.Visible = sidebarIsOpened

    end)

    Runloop = RunService.Heartbeat:Connect(function(deltaTime: number)
        ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, (#Buttons * Config.Menu.ButtonSize) + (Config.Menu.ToolButtonPadding * (#Buttons + 1)))
        ScrollingPadding.PaddingLeft = UDim.new(
            0, 
            
            if (ScrollingFrame.CanvasSize.Height.Offset > ScrollingFrame.AbsoluteSize.Y) then 
                Config.Menu.ToolButtonPadding 
            else 
                0
        )

        Arrow.Size = UDim2.new(
            Arrow.Size.Width, 
            UDim.new(
                Arrow.Size.Height.Scale,
                math.min(Config.Menu.ArrowHeight, MenuFrame.AbsoluteSize.Y - Config.Menu.ToolButtonPadding * 2)
            )
        )

        if (CurrentTool and CurrentTool.OnTick) then
            CurrentTool.OnTick(CurrentTool, deltaTime)
        end
    end)

    widget:BindToClose(function()
        Runloop:Disconnect()
    end)

    local UpdateLog
    local retries = 0

    task.spawn(function()
        local success, errorcode = pcall(function()
            UpdateLog = HttpService:GetAsync(Config.Architect.RawRepositoryUrl..Config.Architect.UpdateLogUrl, true)
        end)

        if (not success) then
            warn("Optimize Architect failed to load the Update Log. This could be a problem with your internet connection.")
            warn("Error code:", errorcode)
        end
    end)

    task.spawn(function()
        
        repeat 
            task.wait() 
            retries += 1 
        until 
            (UpdateLog) or (retries > 500)

        if (not UpdateLog) then return end
        local updateData: Types.UpdateLog = HttpService:JSONDecode(UpdateLog)
        if (not updateData) then return end
        local recentUpdate = updateData[#updateData]
        if (not recentUpdate) then return end

        local recentVersion = recentUpdate.Version
        local currentVersion = Config.Architect.CurrentVersion

        if (recentVersion > currentVersion) then

            local warningLabel: TextLabel = MenuScope:New "TextLabel" {
                Size = UDim2.new(1, -49, 0.25, 0),
                BackgroundTransparency = 1,
                TextColor3 = Color3.new(1, 1, 1),
                Font = Enum.Font.JosefinSans,
                Text = "UPDATE AVAILABLE: "..recentUpdate.Name,
                TextScaled = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 10001
            }

            warningLabel.FontFace.Bold = true
            local warningBox: Frame

            warningBox = MenuScope:New "Frame" {
                Position = UDim2.new(0, 0, 0, -70),
                Size = UDim2.new(1, 0, 0, 60),
                ZIndex = 10000,
                BackgroundColor3 = Config.Colors.UpdateWarning,

                [Children] = {
                    MenuScope:New "UICorner" {
                        CornerRadius = Config.Menu.CornerRadius
                    },
                    warningLabel,
                    MenuScope:New "UIPadding" {
                        PaddingBottom = UDim.new(0, 4),
                        PaddingLeft = UDim.new(0, 4),
                        PaddingRight = UDim.new(0, 4),
                        PaddingTop = UDim.new(0, 8)
                    },
                    MenuScope:New "TextLabel" {
                        Position = UDim2.new(0, 0, 0.25, 4),
                        Size = UDim2.new(1, 0, 0.8, -4),
                        TextColor3 = Color3.new(0.8, 0.84, 0.9),
                        Font = Enum.Font.JosefinSans,
                        TextScaled = true,
                        ZIndex = 10001,
                        BackgroundTransparency = 1,
                        Text = recentUpdate.Description,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextYAlignment = Enum.TextYAlignment.Top
                    },
                    MenuScope:ConstructTextButton {} {
                        Text = "Dismiss",
                        Position = UDim2.new(1, 0, 0, 0),
                        Size = UDim2.new(0, 45, 0.25, 0),
                        TextScaled = true,
                        ZIndex = 10001,
                        AnchorPoint = Vector2.new(1, 0),
                        
                        [MenuScope.OnEvent("MouseButton1Click")] = function()
                            warningBox:Destroy()
                        end
                    }
                }
            }

            warningBox.Parent = MenuFrame

            TweenService:Create(
                warningBox, 
                TweenInfo.new(1.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), 
                { Position = UDim2.new(0, 0, 0, 0) }
            ):Play()
        end

    end)
end

return CreateMenu