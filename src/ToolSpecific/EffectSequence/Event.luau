local Container = {}

export type SequenceSingleton = {
    Time: number,
    SequenceLength: number,
    SequenceSpeed: number,
    Script: Script,
    Parent: Instance,
    Garbage: { RBXScriptSignal }
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
    Meta: (self: Event, sequence: SequenceSingleton, ...any) -> (),
}

function Container.Create(Properties: EventProperties, Meta: (self: Event, sequence: SequenceSingleton, ...any) -> ()): Event
    local createdEvent: Event = {
        Meta = Meta,
        Arguments = Properties.Arguments,
        Dependencies = Properties.Dependencies,
        DisplayName = Properties.DisplayName
    }

    return createdEvent
end

return Container