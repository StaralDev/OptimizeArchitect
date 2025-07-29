local Event = require(script.Parent.Parent.Event)

return Event.Create({
    DisplayName = "Test Event",
    Dependencies = { script },
    Arguments = {
        {
            Name = "Content",
            Type = "string"
        }
    }
}, function(self: Event.Event, sequence: Event.SequenceSingleton, Content: string)
    print("World Says: "..Content)
end)