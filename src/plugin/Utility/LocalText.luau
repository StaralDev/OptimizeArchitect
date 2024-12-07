--[[
    Depending on what language you're using, this module returns the correct text
]]

local LocalText = {}
LocalText.Language = 1

local LocalizationTable = require(script.Parent.Localization.LocalizationTable)

local function GetLocalText(key : string) : string
    if (LocalizationTable[key]) then
        return LocalizationTable[key][LocalText.Language]
    else
        if (LocalizationTable["Error"]) then
            return LocalizationTable["Error"][LocalText.Language]
        else
            return "SUPER RARE ERROR DM ME Staral6861 SEND YOUR OUTPUT"
        end
    end
end

LocalText.GetLocalText = GetLocalText

return LocalText