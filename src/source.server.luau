local Architect = require(script.Parent.setup)
local Tool = require(script.Parent.Menu.Tool)

Tool.SetPlugin(plugin)
Architect(plugin)

--for _, v in script.Parent.Tools:GetChildren() do
--    local newTool: Tool.Tool<any, any> = require(v) :: any
--    if (newTool.OnPluginLoaded) then newTool.OnPluginLoaded(newTool.self) end
--end