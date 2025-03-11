local TweenService = game:GetService("TweenService")
local Types = require(script.Parent.Types)

--[=[
    Tweens a GuiButton. Used in components for automated button transitions when
    actions such as hovering or clicking occour.

    @param Button The button to be tweened.
    @param Transition Some info on the style and duration of the tween.
    @param NewColor The color to transform the button.
    @param Property? The property to be changed (Default: BackgroundColor3)
    @return The tween that is playing.
]=]
local function TweenButton(Button: GuiButton, Transition: Types.TransitionOverride, NewColor: Color3, Property: string?): Tween
    local tween = TweenService:Create(
        Button, 
        TweenInfo.new(Transition.Duration, Transition.EasingStyle, Transition.EasingDirection), 
        {[Property or "BackgroundColor3"] = NewColor}
    )

    tween:Play()
    return tween
end

local function GetStatistics(Selection: {Instance})
    for _, v in Selection do
        
    end
end

return {
    ["TweenButton"] = TweenButton,
}