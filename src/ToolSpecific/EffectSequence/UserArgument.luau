local MenuScope = require(script.Parent.Parent.Parent.Menu.GetMenuScope)

local function Draw(self: UserArgument, scope: typeof(MenuScope()))
    scope:New "Frame" {
        
    }    
end

export type UserArgumentStorageType = "Single" | "Array" | "Map" 

type UserArgument = {
    StorageType: UserArgumentStorageType,
    Type: string,

    RealFrame: typeof(Draw(nil :: any)),
}

export type UserArgumentSingle = UserArgument & { Content: any }
export type UserArgumentArray = UserArgument & { Content: { any } }
export type UserArgumentMap = UserArgument & { Content: { [any]: any } }

local Module = {}

function Module.Create()
    --local RealFrame = Draw()
end


return Module