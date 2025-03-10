local GetMenuScope = require(script.Parent.GetMenuScope)
local menuScope = GetMenuScope()

local Tool: ToolExtra = {} :: any

type ToolConfig = {
    
    --Properties
    Cleanup: { RBXScriptConnection }?,
    
    -- Required
    Enabled: boolean,
    Title: string,

    -- Methods
    OnPluginLoaded: (self: Tool) -> ()?,
    Opened: (self: Tool) -> ()?,
    Closed: (self: Tool) -> ()?,
    OnTick: (self: Tool, DeltaTine: number) -> ()?,

    __ToolExtra: ToolExtra?
}

type ToolExtra = {
    Plugin: Plugin,
    Scope: typeof(menuScope),
    MenuFrame: Frame,
    RegenerateScope: (self: Tool) -> ()
}

export type Tool = typeof(setmetatable({} :: ToolConfig, {__index = {} :: ToolExtra}))

function RegenerateScope(self: Tool)
    assert(self.__ToolExtra)
    self.__ToolExtra.Scope = GetMenuScope(true)
end

function new<T>(t: ToolConfig?): Tool

    assert(t, "New table not provided")

    Tool.Scope = menuScope

    local ToolExtra: ToolExtra = {
        Plugin = Tool.Plugin,
        Scope = GetMenuScope(true),
        MenuFrame = Tool.MenuFrame,
        RegenerateScope = RegenerateScope
    }

    t.__ToolExtra = ToolExtra

    local constructedTool: Tool = setmetatable(t, {__index = ToolExtra})
    print(ToolExtra.Scope.ConstructImageButton)
    if (constructedTool.OnPluginLoaded) then constructedTool.OnPluginLoaded(constructedTool) end
    return constructedTool
end

function setPlugin(plugin: Plugin)
    Tool.Plugin = plugin
end

function setMenuFrame(MenuFrame: Frame)
    Tool.MenuFrame = MenuFrame
end

return {["new"] = new, ["SetPlugin"] = setPlugin, ["SetMenuFrame"] = setMenuFrame}