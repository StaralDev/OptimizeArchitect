local TweenService = game:GetService("TweenService")

local Button = {}
Button.__index = Button

local ColorTweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)

local function ChangeButtonColor(Object : GuiButton, Color : Color3) : Tween
    local builtTween = TweenService:Create(Object, ColorTweenInfo, {BackgroundColor3 = Color})
    builtTween:Play()
    
    return builtTween
end

local function RunFunctionSafe(func : () -> ()?) : boolean
    if (func) then
        func()
        return true
    end
    return false
end

type Button = typeof(setmetatable({} :: {
    
--[[
    Properties
]]    
    ClickableButton : GuiButton,
    Enabled : boolean,

    BaseColor : Color3?,
    HoverColor : Color3?,
    DownColor : Color3?,
    DisabledColor : Color3?,

--[[
    Virtual methods
]]
    OnClicked : () -> ()?,

    OnMouseDown : () -> ()?,
    OnMouseUp : () -> ()?,

    OnMouseEntered : () -> ()?,
    OnMouseExited : () -> ()?

}, Button))

function Button.new(ClickableButton : GuiButton, StartEnabled : boolean) : Button
    
    local self : Button = setmetatable({
        ClickableButton = ClickableButton,
        Enabled = StartEnabled
    }, Button)

    self.ClickableButton.MouseButton1Click:Connect(function()
        RunFunctionSafe(self.OnClicked)
    end)

    self.ClickableButton.MouseButton1Down:Connect(function()
        if (self.DownColor) then
            ChangeButtonColor(self.ClickableButton, self.DownColor)
        end
        RunFunctionSafe(self.OnMouseDown)
    end)

    self.ClickableButton.MouseButton1Up:Connect(function()
        if (self.HoverColor) then
            ChangeButtonColor(self.ClickableButton, self.HoverColor)
        end
        RunFunctionSafe(self.OnMouseUp)
    end)

    self.ClickableButton.MouseEnter:Connect(function()
        if (self.HoverColor) then
            ChangeButtonColor(self.ClickableButton, self.HoverColor)
        end
        RunFunctionSafe(self.OnMouseEntered)
    end)

    self.ClickableButton.MouseLeave:Connect(function()
        if (self.BaseColor) then
            ChangeButtonColor(self.ClickableButton, self.BaseColor)
        end
        RunFunctionSafe(self.OnMouseExited)
    end)

    return self
end

function Button.SetColors(self : Button, BaseColor : Color3, HoverColor : Color3, DownColor : Color3, DisabledColor : Color3)
    self.ClickableButton.AutoButtonColor = false

    self.BaseColor = BaseColor
    self.HoverColor = HoverColor
    self.DownColor = DownColor
    self.DisabledColor = DisabledColor

    ChangeButtonColor(self.ClickableButton, BaseColor)
end


return Button