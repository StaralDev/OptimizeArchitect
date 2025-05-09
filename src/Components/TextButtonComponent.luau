local Fusion = require(script.Parent.Parent.Packages.Fusion)
local Config = require(script.Parent.Parent.Config)
local Util = require(script.Parent.Parent.Util)

local Types = require(script.Parent.Parent.Types)

local function new(
    Scope: Fusion.Scope,
    
    properties: {
        Colors: Types.InteractColorOverride?,
        Transition: Types.TransitionOverride?,
        Enabled: boolean?,
        
        MouseUp: (MousePosition: Vector2) -> ()?,
        MouseDown: (MousePosition: Vector2) -> ()?,
        
        MouseEnter: (MousePosition: Vector2) -> ()?,
        MouseLeave: (MousePosition: Vector2) -> ()?
    }
)

    assert(Scope)
    local button: TextButton
    
    button = Scope:New "TextButton" {
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.JosefinSans,
        BackgroundColor3 = (properties.Colors or Config.Components.DefaultButtonColor).BaseColor,

        [Scope.Children] = {
            Scope:New "UICorner" {
                CornerRadius = Config.Menu.CornerRadius
            }
        },

        [Scope.OnEvent("MouseEnter")] = function(MouseX: number, MouseY: number)
            if (properties.MouseEnter) then properties.MouseEnter(Vector2.new(MouseX, MouseY)) end

            Util.TweenButton(
                button, 
                properties.Transition or Config.Components.DefaultTransition, 
                (properties.Colors or Config.Components.DefaultButtonColor).HoveredColor
            )
        end,

        [Scope.OnEvent("MouseLeave")] = function(MouseX: number, MouseY: number)
            if (properties.MouseLeave) then properties.MouseLeave(Vector2.new(MouseX, MouseY)) end

            Util.TweenButton(
                button, 
                properties.Transition or Config.Components.DefaultTransition,
                (properties.Colors or Config.Components.DefaultButtonColor).BaseColor
            )
        end,

        [Scope.OnEvent("MouseButton1Down")] = function(MouseX: number, MouseY: number)
            if (properties.MouseDown) then properties.MouseDown(Vector2.new(MouseX, MouseY)) end

            Util.TweenButton(
                button, 
                properties.Transition or Config.Components.DefaultTransition,
                (properties.Colors or Config.Components.DefaultButtonColor).InteractedColor
            )
        end,

        [Scope.OnEvent("MouseButton1Up")] = function(MouseX: number, MouseY: number)
            if (properties.MouseUp) then properties.MouseUp(Vector2.new(MouseX, MouseY)) end

            Util.TweenButton(
                button, 
                properties.Transition or Config.Components.DefaultTransition,
                (properties.Colors or Config.Components.DefaultButtonColor).HoveredColor
            )
        end
    } :: any

    return Scope:Hydrate(button)
end


return new