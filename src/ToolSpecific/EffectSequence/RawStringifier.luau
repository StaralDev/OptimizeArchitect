--[[
    Storage Types:
    single
    array
    map

    Data Types:
    * bool
    * number
    * string
    BrickColor
    * CFrame
    * Color3
]]

local RawStringifier = {}

function RawStringifier.BoolToRaw(a: boolean): string
    if (a == true) then return "true"
    else return "false" end
end

function RawStringifier.NumberToRaw(a: number): string
    if not (a) then return "0" end
    local raw = tostring(a)

    if (raw == "nan" or raw == "inf") then return "0" end
    return raw
end

function RawStringifier.StringToRaw(a: string): string
    return `"{a or ""}"`
end

--function RawStringifier.BrickColorToRaw(a: BrickColor): string
--    local assure = a or BrickColor.new("White")
--    return `BrickColor.new({assure.Name})`
--end

function RawStringifier.CFrameToRaw(a: CFrame): string
    local assure = a or CFrame.new(1, 0, 1)
    return `CFrame.new({tostring(assure)})`
end

function RawStringifier.Color3(a: Color3): string
    local assure = a or Color3.new(1, 1, 1)
    return `Color3.fromHex("{assure:ToHex()}")`
end






return RawStringifier