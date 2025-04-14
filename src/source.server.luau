local RunService = game:GetService("RunService")

if (not RunService:IsRunning()) then
    local Architect = require(script.Parent.setup)
    local Tool = require(script.Parent.Menu.Tool)

    Tool.SetPlugin(plugin)
    Architect(plugin)
end