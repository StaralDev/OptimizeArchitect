local Fusion = require(script.Parent.Parent.Packages.Fusion)
local Config = require(script.Parent.Parent.Config)

local function CreateMenu(plugin: Plugin, widget: DockWidgetPluginGui)
    local MenuScope = Fusion:scoped()

    local Children = MenuScope.Children

    local SidebarOpened = MenuScope:Value(true)

    -- The sidebar where you can select a button to open a tool.
    local Sidebar: Frame = MenuScope:New "Frame" {
        Name = "Sidebar",
        BackgroundColor3 = Config.Colors.Sidebar,
        [Children] = {
            MenuScope:New "UICorner" {
                CornerRadius = Config.Menu.CornerRadius
            }
        },
        Size = UDim2.new(0, Config.Menu.SidebarWidth, 1, 0)
    }

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
            Holder
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

        Sidebar.Visible = sidebarIsOpened

    end)

end

return CreateMenu