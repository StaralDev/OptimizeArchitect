local Tool = require(script.Parent.Parent.Menu.Tool)

local NewTool

NewTool = Tool.new { 
    Enabled = true, 
    Title = "Test Tool2",

    Opened = function(self: Tool.Tool)
        local textButton = self.Scope:ConstructTextButton {} {
            Text = "CLICK ME!",
            Size = UDim2.new(1, 0, 0.2, 0),
            Position = UDim2.new(0, 0, 0, 0),
            [self.Scope.OnEvent("MouseButton1Click")] = function()
                print("Finally working!")
            end
        }

        textButton.Parent = self.MenuFrame
        print(textButton)
        print(self.MenuFrame)
    end
}

return NewTool