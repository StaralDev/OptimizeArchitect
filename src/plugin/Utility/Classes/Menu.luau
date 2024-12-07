export type Menu<T> = {
    MenuNameKey : string,
    Enabled : boolean,
    MenuGui : T,

    OnCreation : () -> ()?,
    OnDeletion : () -> ()?,

    OnTick : (DeltaTime : number) -> ()?,

    OnLanguageReload : (
        LocalText : {
            Language : number,
            GetLocalText : (key : string) -> (string)
        }
    ) -> ()?
}

local Menu = {}

Menu.new = function<T>(menuNameKey : string, enabled : boolean, menuGui : T)
    local self : Menu<T> = {
        MenuNameKey = menuNameKey,
        Enabled = enabled,
        MenuGui = menuGui
    }

    return self
end

return Menu