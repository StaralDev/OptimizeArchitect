local Types = require(script.Parent.Types)

local Config = {}

Config.Architect = {
    Name = "Optimized Architect",
    Identifier = "OptimizedArchitect",
    Title = "θptimized Architect",
    Tooltip = "Activate Optimized Architect",
    ButtonName = "Open",
    RepositoryUrl = "https://github.com/StaralDev/OptimizeArchitect",
    RawRepositoryUrl = "https://raw.githubusercontent.com/StaralDev/OptimizeArchitect",
    UpdateLogUrl = "/master/UpdateLog.json",

    CurrentVersion = 0.00
}

Config.Colors = {
    Background = Color3.new(0.145098, 0.164706, 0.227451),
    ScrollBar = Color3.new(0.109804, 0.125490, 0.168627),
    Sidebar = Color3.new(0.160784, 0.180392, 0.254902),
    Holder = Color3.new(0.168627, 0.192157, 0.266667),
    UpdateWarning = Color3.new(0.098039, 0.113725, 0.168627)
}

Config.Menu = {
    MainPadding = UDim.new(0, 12),
    CornerRadius = UDim.new(0, 8),
    SidebarWidth = 128,
    ArrowPadding = 48,
    ArrowHeight = 120,
    ToolButtonPadding = 6,
    ButtonSize = 16,
    ScrollbarThickness = 4,
    ButtonTextSize = 12,
}

Config.Components = {
    DefaultTransition = {
        
        Duration = 0.1,
        EasingStyle = Enum.EasingStyle.Quad,
        EasingDirection = Enum.EasingDirection.InOut

    } :: Types.TransitionOverride,

    DefaultButtonColor = {

        BaseColor = Color3.new(0.254902, 0.298039, 0.439216),
        HoveredColor = Color3.new(0.317647, 0.360784, 0.513725),
        InteractedColor = Color3.new(0.207843, 0.239216, 0.345098),
        DisabledColor = Color3.new(0.309804, 0.329412, 0.392157)

    } :: Types.InteractColorOverride,

    SelectedButtonColor = {
        BaseColor = Color3.new(0.380392, 0.478431, 0.768627),
        HoveredColor = Color3.new(0.403922, 0.501961, 0.800000),
        InteractedColor = Color3.new(0.349020, 0.443137, 0.721569),
        DisabledColor = Color3.new(0.588235, 0.623529, 0.733333)
    }
}

return Config