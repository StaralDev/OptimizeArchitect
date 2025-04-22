local Config = require(script.Parent.Config)
local CreateMenu = require(script.Parent.Menu.CreateMenu)

function Architect(plugin: Plugin)
    local toolbar =  plugin:CreateToolbar(Config.Architect.Title)
    local dockWidgetInfo = DockWidgetPluginGuiInfo.new(
        Enum.InitialDockState.Left,
        false,
        false,
        300, 400,
        200, 300
    )

    local activatorButton = toolbar:CreateButton(
        Config.Architect.Identifier, 
        Config.Architect.Tooltip, 
        "http://www.roblox.com/asset/?id=78032664445396", 
        Config.Architect.ButtonName
    )
    
    local widget = plugin:CreateDockWidgetPluginGui(
        Config.Architect.Name, 
        dockWidgetInfo
    )
    widget.Title = Config.Architect.Title
    
    activatorButton.Click:Connect(function()
        widget.Enabled = not widget.Enabled
        activatorButton:SetActive(widget.Enabled)
    end)

    CreateMenu(plugin, widget, activatorButton)

end

return Architect