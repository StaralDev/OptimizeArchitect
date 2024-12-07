local TweenService : TweenService = game:GetService("TweenService")

local FlipToggle = {}
FlipToggle.__index = FlipToggle

local ColorTweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)

local function ChangeMoverColor(Mover : ImageLabel, Color : Color3) : Tween
    local builtTween = TweenService:Create(Mover, ColorTweenInfo, {ImageColor3 = Color})
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

export type FlipToggle = typeof(setmetatable({} :: {

--[[
    Properties
]]

    Button : GuiButton,
    UntoggledLocation : UDim2,
    ToggledLocation : UDim2,
    Mover : ImageLabel,
    TravelTime : number,
    Toggled : boolean,

    Enabled : boolean,

    BaseColor : Color3?,
    HoverColor : Color3?,
    DisabledColor : Color3?,

    ButtonHovered : boolean?,

--[[
    Virtual methods
]]

    OnToggled : () -> ()?,
    OnUntoggled : () -> ()?,

    OnClicked : () -> ()?,

    OnMouseDown : () -> ()?,
    OnMouseUp : () -> ()?,

    OnMouseEntered : () -> ()?,
    OnMouseExited : () -> ()?


}, FlipToggle))

function FlipToggle.new(Button : GuiButton, UntoggledLocation : UDim2, ToggledLocation : UDim2, Mover : ImageLabel, TravelTime : number, StartToggled : boolean?) : FlipToggle
    local self : FlipToggle = setmetatable({
        
        Button = Button,
        UntoggledLocation = UntoggledLocation,
        ToggledLocation = ToggledLocation,
        Mover = Mover,
        TravelTime = TravelTime,
        Toggled = StartToggled,
        Enabled = true

    }, FlipToggle)

    Button.MouseButton1Click:Connect(function()
        self:SetToggled(not self.Toggled)
        RunFunctionSafe(self.OnClicked)
    end)

    Button.MouseButton1Down:Connect(function()
        RunFunctionSafe(self.OnMouseDown)
    end)

    Button.MouseButton1Up:Connect(function()
        RunFunctionSafe(self.OnMouseUp)
    end)

    Button.MouseEnter:Connect(function()
        self.ButtonHovered = true
        self:UpdateColor()
        RunFunctionSafe(self.OnMouseEntered)
    end)

    Button.MouseLeave:Connect(function()
        self.ButtonHovered = false
        self:UpdateColor()
        RunFunctionSafe(self.OnMouseExited)
    end)

    return self
end

function FlipToggle.SetEnabled(self : FlipToggle, Enabled : boolean)
    self.Enabled = Enabled
    self:UpdateColor()
end

function FlipToggle.SetToggled(self : FlipToggle, Toggled : boolean)
    self.Toggled = Toggled

    if (self.Toggled) then
        TweenService:Create(self.Mover, TweenInfo.new(self.TravelTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = self.ToggledLocation}):Play()
        RunFunctionSafe(self.OnToggled)
    else
        TweenService:Create(self.Mover, TweenInfo.new(self.TravelTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = self.UntoggledLocation}):Play()
        RunFunctionSafe(self.OnUntoggled)
    end

    self:UpdateColor()
end

function FlipToggle.UpdateColor(self : FlipToggle)
    if (self.BaseColor and self.HoverColor and self.DisabledColor) then
        
        if (self.Enabled) then
            if (self.ButtonHovered) then
                ChangeMoverColor(self.Mover, self.HoverColor)
            else
                ChangeMoverColor(self.Mover, self.BaseColor)
            end
        else
            ChangeMoverColor(self.Mover, self.DisabledColor)
        end

    end
end

function FlipToggle.SetColors(self : FlipToggle, BaseColor : Color3, HoverColor : Color3, DisabledColor : Color3)
    self.BaseColor = BaseColor
    self.HoverColor = HoverColor
    self.DisabledColor = DisabledColor
end

return FlipToggle