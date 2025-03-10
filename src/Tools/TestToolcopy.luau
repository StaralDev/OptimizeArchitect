local Tool = require(script.Parent.Parent.Menu.Tool)

local NewTool = Tool.new { Enabled = true, Title = "Test Tool1" }
local Scope = NewTool.Scope

NewTool.self = {
    
}

NewTool.Opened = function()

end

return NewTool