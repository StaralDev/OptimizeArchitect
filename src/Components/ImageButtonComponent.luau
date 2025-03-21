local Fusion = require(script.Parent.Parent.Packages.Fusion)
local Config = require(script.Parent.Parent.Config)
local Util = require(script.Parent.Parent.Util)

local Types = require(script.Parent.Parent.Types)

local function new(
    Scope: Fusion.Scope,
    
    properties: {
        Colors: Types.InteractColorOverride?,
        BackgroundColors: Types.InteractColorOverride?,
        Transition: Types.TransitionOverride?,
        Corner: UDim?,
        Enabled: boolean?,
        DontChangeColor: boolean?,
        PropertyToChange: "ImageColor3" | "BackgroundColor3" | string | nil,
        
        MouseUp: (MousePosition: Vector2) -> ()?,
        MouseDown: (MousePosition: Vector2) -> ()?,
        
        MouseEnter: (MousePosition: Vector2) -> ()?,
        MouseLeave: (MousePosition: Vector2) -> ()?
    }
)

    assert(Scope)
    local button: ImageButton

    properties.PropertyToChange = properties.PropertyToChange or "ImageColor3"
    
    button = Scope:New "ImageButton" {
        [properties.PropertyToChange or "ImageColor3"] = (properties.Colors or Config.Components.DefaultButtonColor).BaseColor,

        [Scope.OnEvent("MouseEnter")] = function(MouseX: number, MouseY: number)
            if (properties.MouseEnter) then properties.MouseEnter(Vector2.new(MouseX, MouseY)) end

            if (properties.DontChangeColor) then return end
            Util.TweenButton(
                button, 
                properties.Transition or Config.Components.DefaultTransition, 
                (properties.Colors or Config.Components.DefaultButtonColor).HoveredColor,
                properties.PropertyToChange
            )

            if (properties.BackgroundColors) then
                Util.TweenButton(
                    button, 
                    properties.Transition or Config.Components.DefaultTransition, 
                    properties.BackgroundColors.HoveredColor
                )
            end
        end,

        [Scope.OnEvent("MouseLeave")] = function(MouseX: number, MouseY: number)
            if (properties.MouseLeave) then properties.MouseLeave(Vector2.new(MouseX, MouseY)) end

            if (properties.DontChangeColor) then return end

            Util.TweenButton(
                button, 
                properties.Transition or Config.Components.DefaultTransition,
                (properties.Colors or Config.Components.DefaultButtonColor).BaseColor,
                properties.PropertyToChange
            )

            if (properties.BackgroundColors) then
                Util.TweenButton(
                    button, 
                    properties.Transition or Config.Components.DefaultTransition, 
                    properties.BackgroundColors.BaseColor
                )
            end
        end,

        [Scope.OnEvent("MouseButton1Down")] = function(MouseX: number, MouseY: number)
            if (properties.MouseDown) then properties.MouseDown(Vector2.new(MouseX, MouseY)) end

            if (properties.DontChangeColor) then return end

            Util.TweenButton(
                button, 
                properties.Transition or Config.Components.DefaultTransition,
                (properties.Colors or Config.Components.DefaultButtonColor).InteractedColor,
                properties.PropertyToChange
            )

            if (properties.BackgroundColors) then
                Util.TweenButton(
                    button, 
                    properties.Transition or Config.Components.DefaultTransition, 
                    properties.BackgroundColors.InteractedColor
                )
            end
        end,

        [Scope.OnEvent("MouseButton1Up")] = function(MouseX: number, MouseY: number)
            if (properties.MouseUp) then properties.MouseUp(Vector2.new(MouseX, MouseY)) end

            if (properties.DontChangeColor) then return end

            Util.TweenButton(
                button, 
                properties.Transition or Config.Components.DefaultTransition,
                (properties.Colors or Config.Components.DefaultButtonColor).HoveredColor,
                properties.PropertyToChange
            )

            if (properties.BackgroundColors) then
                Util.TweenButton(
                    button, 
                    properties.Transition or Config.Components.DefaultTransition, 
                    properties.BackgroundColors.HoveredColor
                )
            end
        end
    } :: any

    if (properties.Corner) then
        local corner: UICorner = Scope:New "UICorner" {
            CornerRadius = properties.Corner
        } :: any

        corner.Parent = button
    end

    return Scope:Hydrate(button)
end


return new