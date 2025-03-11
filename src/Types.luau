--[=[
    Used to store a regularly used color and a disabled color for when
    the element is disabled.
]=]
export type ColorOverride = {
    BaseColor: Color3,
    DisabledColor: Color3
}

--[=[
    Used by interactable items to store colors.
]=]
export type InteractColorOverride = ColorOverride & {
    HoveredColor: Color3,
    InteractedColor: Color3
}

--[=[
    Used by Toggles when needed to have multiple InteractColorOverrides.
]=]
export type SwitchColorOverride = {[number]:InteractColorOverride}

--[=[
    Used during a transition to determine the style and speed of the transition.
]=]
export type TransitionOverride = {
    Duration: number,
    EasingStyle: Enum.EasingStyle,
    EasingDirection: Enum.EasingDirection
}

export type Cleanup = { RBXScriptConnection }

export type Statistics<T> = {
    Instances: T,

    Beams: T,
    BeamSegments: T,

    Constraints: T,
    Attachments: T,

    ParticleEmitters: T,
    EnabledEmitters: T,

    ParticlesOnAverage: T,
    ParticleMass: T
}

export type StatisticData = {
    Warning: number?,
    Dangerous: number?,
    Cataclysmic: number?,
    DisplayName: string,
    
    UseMeter: boolean?
}

return nil