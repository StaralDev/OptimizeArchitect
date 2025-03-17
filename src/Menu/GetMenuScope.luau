local Fusion = require(script.Parent.Parent.Packages.Fusion)
local Components = script.Parent.Parent.Components
local Presets = script.Parent.Parent.Presets

local menuScope

return function(generate: boolean?): typeof(menuScope)
    if ((not menuScope) or generate) then
        local newScope = Fusion:scoped({
            ConstructTextButton = require(Components.TextButtonComponent),
            ConstructImageButton = require(Components.ImageButtonComponent),
            ConstructTextToggle = require(Components.TextToggleComponent),
            
            PresetTextLabel = require(Presets.TextLabelPreset)
        })

        if (generate) then
            return newScope
        else
            menuScope = newScope
            return menuScope
        end
    end

    return menuScope
end