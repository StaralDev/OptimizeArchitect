local Fusion = require(script.Parent.Parent.Packages.Fusion)
local Config = require(script.Parent.Parent.Config)

local function CreateMenu(plugin: Plugin, widget: DockWidgetPluginGui)
    local MenuScope = Fusion:scoped()

    local Children = MenuScope.Children

    local MenuFrame = MenuScope:New "Frame" {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Config.Colors.Background,
        [Children] = {
            MenuScope:New "UIPadding" {
                PaddingBottom = Config.Menu.MainPadding,
                PaddingLeft = Config.Menu.MainPadding,
                PaddingRight = Config.Menu.MainPadding,
                PaddingTop = Config.Menu.MainPadding
            },

            MenuScope:New "Frame" {
                Name = "Sidebar",
                BackgroundColor3 = Config.Colors.Sidebar,
                [Children] = {
                    MenuScope:New "UICorner" {
                        CornerRadius = Config.Menu.CornerRadius
                    }
                },
                Size = UDim2.new(0, Config.Menu.SidebarWidth, 1, 0)
            },

            MenuScope:New "Frame" {
                Name = "Holder",
                BackgroundColor3 = Config.Colors.Holder,
                [Children] = {
                    MenuScope:New "UICorner" {
                        CornerRadius = Config.Menu.CornerRadius
                    }
                },
                Size = UDim2.new(1, 0-Config.Menu.SidebarWidth-Config.Menu.ArrowPadding, 1, 0),
                AnchorPoint = Vector2.new(1, 0),
                Position = UDim2.new(1, 0, 0, 0)
            }
        }
    }
    MenuFrame.Parent = widget

end

return CreateMenu