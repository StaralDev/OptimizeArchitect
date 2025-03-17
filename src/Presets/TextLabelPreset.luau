local Fusion = require(script.Parent.Parent.Packages.Fusion)

local function new(Scope: Fusion.Scope)
    local label = Scope:New "TextLabel" {
        Font = Enum.Font.JosefinSans,
        TextColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = 1
    }

    return Scope:Hydrate(label)
end

return new