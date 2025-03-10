local RunService = game:GetService("RunService")

local Config = require(script.Parent.Parent.Config)
local Tool = require(script.Parent.Tool)

local MenuScope = require(script.Parent.GetMenuScope)()
local CurrentTool: Tool.Tool? = nil

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

    
    -- The holder that contains the selected tool.
    local Holder: Frame = MenuScope:New "Frame" {
        Name = "Holder",
        BackgroundColor3 = Config.Colors.Holder,
        [Children] = {
            MenuScope:New "UICorner" {
                CornerRadius = Config.Menu.CornerRadius
            }
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

    local Arrow: ImageButton = MenuScope:ConstructImageButton {} {
        BackgroundTransparency = 1,
        Image = "http://www.roblox.com/asset/?id=8317995440",
        Position = UDim2.new(0, Config.Menu.SidebarWidth + Config.Menu.ToolButtonPadding, 0.5, 0),
        Size = UDim2.new(0, Config.Menu.ArrowPadding - Config.Menu.ToolButtonPadding * 2, 0, 120),
        Rotation = 180,
        AnchorPoint = Vector2.new(0, 0.5),
        ZIndex = 20,
        [MenuScope.OnEvent("MouseButton1Click")] = function()
            SidebarOpened:set(not MenuScope.peek(SidebarOpened))
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
end

return CreateMenu