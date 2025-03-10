local Tool = require(script.Parent.Parent.Menu.Tool)

local NewTool = Tool.new { Enabled = true, Title = "Test Tool" }

NewTool.self = {
    
}

NewTool.Opened = function()
    
end

return NewTool