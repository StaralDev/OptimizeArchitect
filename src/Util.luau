--!nolint LocalShadow

local TweenService = game:GetService("TweenService")
local Types = require(script.Parent.Types)
local Config = require(script.Parent.Config)

local function Lerp<T>(a: T, b: T, t: number): T
    local a = a :: any
    local b = b :: any

    return a + (b - a) * t
end

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

--[=[
    Changes the HSV of a Color3 by specified amounts.

    @param Original The Color3 to act on.
    @param hueBoost The amount of Hue to be added (This parameter loops, meaning numbers greater than 1 end up back around).
    @param saturationBoost The amount of Saturation to be added.
    @param valueBoost The amount of Value to be added.
    @return The modified Color3.
]=]
local function ModifyHSV(Original: Color3, hueBoost: number, saturationBoost: number, valueBoost: number): Color3
    local h, s, v = Original:ToHSV()
    return Color3.fromHSV((h+hueBoost)%1, math.clamp(s+saturationBoost, 0, 1), math.clamp(v+valueBoost, 0, 1))
end

--[=[
    Creates an InteractColorOverride from automatic parameters given a BaseColor.

    @param Base The Color3 for the automatic parameters to be applied to.
    @return An InteractColorOverride from the BaseColor.
]=]
local function AutoGenerateColors(Base: Color3): Types.InteractColorOverride
    return {
        BaseColor = Base,
        DisabledColor = ModifyHSV(Base, 0, -0.2, 0),
        HoveredColor = ModifyHSV(Base, 0, 0.07, 0.15),
        InteractedColor = ModifyHSV(Base, 0, 0.07, -0.15)
    }
end

--[=[
    Gets data from an emitter about it's EmitVFX Attributes.

    @param Emitter The ParticleEmitter to be checked.
    @return The emit data about the ParticleEmitter.
]=]
local function GetEmitVFXData(Emitter: ParticleEmitter): Types.EmitVFXData
    return {
        EmitCount = Emitter:GetAttribute("EmitCount") or 0,
        EmitDelay = Emitter:GetAttribute("EmitDelay") or 0,
        EmitDuration = Emitter:GetAttribute("EmitDuration") or 0,
        EmitRepeatCount = Emitter:GetAttribute("EmitRepeatCount") or 0,
        EmitRepeatDelay = Emitter:GetAttribute("EmitRepeatDelay") or 0
    }
end

--[=[
    Returns the Average Particles that should be emitted from the ParticleEmitter
    and active in the World at any moment.

    @param Emitter The ParticleEmitter to be checked.
    @return The Particles/Avg for the ParticleEmitter.
]=]
local function GetParticlesAverage(Emitter: ParticleEmitter): number
    return Emitter.Rate * ((Emitter.Lifetime.Min + Emitter.Lifetime.Max)/2)
end

--[=[
    Returns the Particles that are being emitted every Second from the
    ParticleEmitter.

    @param Emitter the ParticleEmitter to be checked.
    @return The Particles/Sec for the ParticleEmitter.
]=]
local function GetParticlesSecond(Emitter: ParticleEmitter): number
    return Emitter.Rate * Emitter.TimeScale
end

--[=[
    Returns the amount of Particles that should appear when Emitted
    from an Emitter using a plugin (i.e. VFXSuite, EasyVFX) or by playing 
    it using a Script.

    This uses the Attributes provided by the said plugins.

    @param Emitter The ParticleEmitter to be checked.
    @return The Particles/Emit for the ParticleEmitter.
]=]
local function GetParticlesEmit(Emitter: ParticleEmitter): number
    local emitterData = GetEmitVFXData(Emitter)

    local burstAmount = emitterData.EmitCount
    local durationAmount = Emitter.Rate * Emitter.TimeScale * emitterData.EmitDuration

    --[[ 
        Okay this is sort of a hack but I'm assuming that some people are
        gonna be setting their EmitRepeatCounts to obnoxiously large numbers 
        and then are going to get really confused on why the Particles/Emit
        is in the trillions.

        Instead, if you decide you're going to have your EmitRepeatCounts repeat
        forever, I'll just show you the normal amount.
    ]]
    local repeatAmount = if (emitterData.EmitRepeatCount > Config.Optometer.MaxEmitRepeatCount) then 
        emitterData.EmitCount * emitterData.EmitRepeatCount 
    else 0

    return burstAmount + durationAmount + repeatAmount
end

--[=[
    Returns the amount of Particles/Avg that should appear when Emitted
    from an Emitter using a plugin (i.e. VFXSuite, EasyVFX) or by playing
    it using a Script.

    The uses the Attributes provided by the said plugins.

    @param The ParticleEmitter to be checked.
    @return the Particles/Emit for the ParticleEmitter.
]=]
local function GetParticlesAverageEmit(Emitter: ParticleEmitter)
    local emitterData = GetEmitVFXData(Emitter)
    local averageLifetime = (Emitter.Lifetime.Min + Emitter.Lifetime.Max)/2
    
    local repeatMultiplier = if (emitterData.EmitRepeatCount > Config.Optometer.MaxEmitRepeatCount) then
        Config.Optometer.MaxEmitRepeatCount + 1
    else
        1

    local particlesAvg = Emitter.Rate * repeatMultiplier * averageLifetime

    local burstAmount = emitterData.EmitCount * averageLifetime
    local averageAmount = Lerp(particlesAvg/2, particlesAvg, 1/(emitterData.EmitDuration * repeatMultiplier))

    return burstAmount + averageAmount
end

--[=[
    Returns Statistics relevent to Optimization for a selection of Instances.

    @param Selection the Instances to be checked.
    @return A list of Statistics about the Instances.
]=]
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

            collection.ParticlesOnAveragePerEmit += GetParticlesAverageEmit(v)
            collection.ParticlesPerEmit += GetParticlesEmit(v)

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
    
    ["GetStatistics"] = GetStatistics,

    ["GetParticlesAverage"] = GetParticlesAverage,
    ["GetParticlesAverageEmit"] = GetParticlesAverageEmit,
    ["GetParticlesSecond"] = GetParticlesSecond,
    ["GetParticlesEmit"] = GetParticlesEmit,
}