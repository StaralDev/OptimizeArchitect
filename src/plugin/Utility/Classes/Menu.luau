export type Menu<T> = typeof(setmetatable({} :: {
    MenuNameKey : string,
    Enabled : boolean,
    MenuGui : T,

    OnCreation : (MenuGui : T) -> ()?,
    OnDeletion : (MenuGui : T) -> ()?,

    OnTick : (MenuGui : T, DeltaTime : number) -> ()?,

    OnLanguageReload : (
        MenuGui : T,
        LocalText : {
            Language : number,
            GetLocalText : (key : string) -> (string)
        }
    ) -> ()?
}, {__index = {} :: any}))

local Menu = {}

Menu.new = function<T>(menuNameKey : string, enabled : boolean, menuGui : T, this : any)
    local self : Menu<T> = setmetatable({
        MenuNameKey = menuNameKey,
        Enabled = enabled,
        MenuGui = menuGui
    }, {__index = this})

    return self
end

return Menu