local Container = {}

local function GetPropertyWrapper()
    
end

local function Fire(self: Event, sequence: SequenceSingleton, ...:any)
    table.insert(sequence.Events, self)
    self:Meta(sequence, ...)
end

export type SequenceSingleton = {
    --[[
        A number greater than 0 that describes what 
        position the sequence is at. This number
        does not loop.
    ]]
    Time: number,
    --[[
        The total duration of the sequence.
    ]]
    SequenceLength: number,
    --[[
        The speed of the sequence.
    ]]
    SequenceSpeed: number,
    --[[
        The local or global script that the sequence
        is under.
    ]]
    Script: Script,
    --[[
        The owner of the sequence.
    ]]
    Parent: Instance,
    --[[
        Whether the sequence is being run on the server
        or the client.
    ]]
    IsServer: boolean,
    Events: { Event },
}

export type Argument = {
    Name: string,
    Type: string
}

type EventProperties = {
    Arguments : { [number]: Argument },
    Dependencies: { ModuleScript },
    DisplayName: string
}

export type Event = EventProperties & {
    Fire: typeof(Fire),
    Garbage: { RBXScriptSignal },
    GetPropertyWrapper: typeof(GetPropertyWrapper),
    Meta: typeof(Fire),
}

function Container.Create(Properties: EventProperties, Meta: typeof(Fire)): Event
    local createdEvent: Event = {
        Meta = Meta,
        Arguments = Properties.Arguments,
        Dependencies = Properties.Dependencies,
        DisplayName = Properties.DisplayName,

        GetPropertyWrapper = GetPropertyWrapper,
        Fire = Fire,
        Garbage = {},
    }

    return createdEvent
end

return Container