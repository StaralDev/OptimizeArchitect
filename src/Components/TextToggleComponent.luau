local Fusion = require(script.Parent.Parent.Packages.Fusion)
local Config = require(script.Parent.Parent.Config)
local Util = require(script.Parent.Parent.Util)

local Types = require(script.Parent.Parent.Types)

local function new(
    Scope: Fusion.Scope,
    
    properties: {
        UntoggledColors: Types.InteractColorOverride,
        ToggledColors: Types.InteractColorOverride,
        Transition: Types.TransitionOverride?,
        Enabled: boolean?,
        
        MouseUp: (MousePosition: Vector2) -> ()?,
        MouseDown: (MousePosition: Vector2) -> ()?,
        
        MouseEnter: (MousePosition: Vector2) -> ()?,
        MouseLeave: (MousePosition: Vector2) -> ()?,

        OnEnabled: () -> ()?,
        OnDisabled: () -> ()?,
        OnToggle: () -> ()?
    }
)

    assert(Scope)
    local button: TextButton
    local selectedColors = if (properties.Enabled) then properties.ToggledColors else properties.UntoggledColors
    
    local clicking = false
    local inZone = false

    button = Scope:New "TextButton" {
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.JosefinSans,
        BackgroundColor3 = selectedColors.BaseColor,

        [Scope.Children] = {
            Scope:New "UICorner" {
                CornerRadius = Config.Menu.CornerRadius
            }
        },

        [Scope.OnEvent("MouseEnter")] = function(MouseX: number, MouseY: number)
            if (properties.MouseEnter) then properties.MouseEnter(Vector2.new(MouseX, MouseY)) end

            inZone = true

            Util.TweenButton(
                button, 
                properties.Transition or Config.Components.DefaultTransition, 
                selectedColors.HoveredColor
            )
        end,

        [Scope.OnEvent("MouseLeave")] = function(MouseX: number, MouseY: number)
            if (properties.MouseLeave) then properties.MouseLeave(Vector2.new(MouseX, MouseY)) end

            inZone = false

            Util.TweenButton(
                button, 
                properties.Transition or Config.Components.DefaultTransition,
                selectedColors.BaseColor
            )
        end,

        [Scope.OnEvent("MouseButton1Down")] = function(MouseX: number, MouseY: number)
            if (properties.MouseDown) then properties.MouseDown(Vector2.new(MouseX, MouseY)) end

            clicking = true

            Util.TweenButton(
                button, 
                properties.Transition or Config.Components.DefaultTransition,
                selectedColors.InteractedColor
            )
        end,

        [Scope.OnEvent("MouseButton1Up")] = function(MouseX: number, MouseY: number)
            if (properties.MouseUp) then properties.MouseUp(Vector2.new(MouseX, MouseY)) end

            clicking = false
            
            Util.TweenButton(
                button, 
                properties.Transition or Config.Components.DefaultTransition,
                selectedColors.HoveredColor
            )
        end,

        [Scope.OnEvent("MouseButton1Click")] = function()
            button:SetAttribute("Enabled", not button:GetAttribute("Enabled"))
        end
    } :: any
    
    button:SetAttribute("Enabled", properties.Enabled or false)
    Util.TweenButton(
        button, 
        properties.Transition or Config.Components.DefaultTransition, 
        selectedColors[if (clicking) then "InteractedColor" elseif (inZone) then "HoveredColor" else "BaseColor"]
    )

    button:GetAttributeChangedSignal("Enabled"):Connect(function()
        local enabled = button:GetAttribute("Enabled")
        
        if (enabled) then
            selectedColors = properties.ToggledColors
            if (properties.OnEnabled) then properties.OnEnabled() end
        else
            selectedColors = properties.UntoggledColors
            if (properties.OnDisabled) then properties.OnDisabled() end
        end

        if (properties.OnToggle) then properties.OnToggle() end

        Util.TweenButton(
            button, 
            properties.Transition or Config.Components.DefaultTransition, 
            selectedColors[if (clicking) then "InteractedColor" elseif (inZone) then "HoveredColor" else "BaseColor"]
        )
    end)

    return Scope:Hydrate(button)
end


return new