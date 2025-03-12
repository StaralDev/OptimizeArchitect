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

local function ModifyHSV(Original: Color3, hueBoost: number, saturationBoost: number, valueBoost: number): Color3
    local h, s, v = Original:ToHSV()
    return Color3.fromHSV((h+hueBoost)%1, math.clamp(s+saturationBoost, 0, 1), math.clamp(v, 0, 1))
end

local function AutoGenerateColors(Base: Color3): Types.InteractColorOverride
    return {
        BaseColor = Base,
        DisabledColor = ModifyHSV(Base, 0, -0.2, 0),
        HoveredColor = ModifyHSV(Base, 0, 0.07, 0.15),
        InteractedColor = ModifyHSV(Base, 0, 0.07, -0.15)
    }
end

local function GetStatistics(Selection: {Instance})
    for _, v in Selection do
        
    end
end

return {
    ["TweenButton"] = TweenButton,
    ["AutoGenerateColors"] = AutoGenerateColors,
    ["ModifyHSV"] = ModifyHSV
}