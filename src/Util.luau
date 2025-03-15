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

local function GetParticlesAverage(Emitter: ParticleEmitter): number
    return Emitter.Rate * ((Emitter.Lifetime.Min + Emitter.Lifetime.Max)/2)
end

local function GetParticlesSecond(Emitter: ParticleEmitter): number
    return Emitter.Rate * Emitter.TimeScale
end

local function GetStatistics(Selection: {Instance})
    local collection: Types.Statistics<number> = {
        Instances = 0,
        Parts = 0,
        Beams = 0,
        EnabledBeams = 0,
        BeamSegments = 0,
        Constraints = 0,
        Attachments = 0,
        Motors = 0,
        Trails = 0,
        EnabledTrails = 0,
        ParticleEmitters = 0,
        EnabledEmitters = 0,
        ParticlesOnAverage = 0,
        ParticlesOnAveragePerEmit = 0,
        ParticlesPerSecond = 0,
        ParticlesPerEmit = 0,
    }
    local counted: {Instance} = {}

    for _, v in Selection do
        
        if (table.find(counted, v)) then continue end
        table.insert(counted, v)
        
        collection.Instances += 1

        if (v:IsA("BasePart")) then
            collection.Parts += 1
        elseif (v:IsA("Beam")) then
            collection.Beams += 1

            if (v.Enabled) then
                collection.EnabledBeams += 1
                collection.BeamSegments += v.Segments
            end

        elseif (v:IsA("Constraint")) then
            collection.Constraints += 1
        elseif (v:IsA("Motor6D")) then
            collection.Motors += 1
        elseif (v:IsA("ParticleEmitter")) then
            collection.ParticleEmitters += 1

            if (v.Enabled) then
                collection.EnabledEmitters += 1
                collection.ParticlesOnAverage += GetParticlesAverage(v)
                collection.ParticlesPerSecond += GetParticlesSecond(v)
            end


        elseif (v:IsA("Trail")) then
            collection.Trails += 1

            if (v.Enabled) then
                collection.EnabledTrails += 1
            end
        end
    end
end

return {
    ["TweenButton"] = TweenButton,
    ["AutoGenerateColors"] = AutoGenerateColors,
    ["ModifyHSV"] = ModifyHSV,
    ["GetStatistics"] = GetStatistics
}