local GetMenuScope = require(script.Parent.Parent.Menu.GetMenuScope)
local Fusion = require(script.Parent.Parent.Packages.Fusion)
local MenuScope = GetMenuScope()

local Decal = "http://www.roblox.com/asset/?id=9405926389"

local function InformationButton(MenuScope: typeof(MenuScope), Properties: {
    MenuFrame: GuiBase
}) : ({}) -> (ImageButton)
    local button = MenuScope:ConstructImageButton {
        Enabled = true,
        Colors = {
            BaseColor = Color3.new(1, 1, 1),
            HoveredColor = Color3.fromHSV(0.627660, 0.3, 0.8),
            InteractedColor = Color3.fromHSV(0.627660, 0.3, 0.8),
            DisabledColor = Color3.new(1, 1, 1)
        },

        MouseEnter = function()
            
        end,

        MouseLeave = function()

        end
    }

    return MenuScope:Hydrate(button)
end

return InformationButton