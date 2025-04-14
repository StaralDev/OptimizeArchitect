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

    CurrentVersion = 0.01
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
    SidebarWidth = 112,
    ArrowPadding = 48,
    ArrowHeight = 120,
    ToolButtonPadding = 6,
    ButtonSize = 16,
    ScrollbarThickness = 4,
    ButtonTextSize = 12,
    MenuMinimumSize = 360,
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

local OptometerData: Types.Statistics<Types.StatisticData> = {
    Instances = {
        ManualOrder = -999,
        High = 500,
        Dangerous = 1000,
        Cataclysmic = 2000,
        Max = 2500,
        ShowHighestWarningAsMax = true,

        DisplayName = "Instances",
        UseMeter = true
    },

    Parts = {
        ManualOrder = -900,
        High = 150,
        Dangerous = 300,
        Cataclysmic = 1000,
        Max = 1150,
        ShowHighestWarningAsMax = true,

        DisplayName = "Parts",
        UseMeter = true,
    },

    Beams = {
        ManualOrder = 18,
        DisplayName = "Beams",
        UseMeter = false
    },

    EnabledBeams = {
        ManualOrder = 19,
        DisplayName = "Enabled Beams",
        UseMeter = false
    },

    BeamSegments = {
        ManualOrder = 15,
        High = 2000,
        Dangerous = 4000,
        Cataclysmic = 8000,
        Max = 8500,
        ShowHighestWarningAsMax = true,

        DisplayName = "Beam Segments",
        UseMeter = true
    },

    Constraints = {
        ManualOrder = 50,
        DisplayName = "Constraints",
        UseMeter = false
    },

    Attachments = {
        ManualOrder = 20,
        DisplayName = "Attachments",
        UseMeter = false
    },

    Motors = {
        ManualOrder = 21,
        DisplayName = "Motor6Ds",
        UseMeter = false
    },

    Trails = {
        ManualOrder = 22,
        DisplayName = "Trails",
        UseMeter = false
    },

    EnabledTrails = {
        ManualOrder = 23,
        DisplayName = "EnabledTrails",
        UseMeter = false
    },

    ParticleEmitters = {
        ManualOrder = 10,
        DisplayName = "ParticleEmitters",
        UseMeter = false
    },

    EnabledEmitters = {
        ManualOrder = 11,
        DisplayName = "Enabled ParticleEmitters",
        UseMeter = false
    },

    ParticlesOnAverage = {
        ManualOrder = -10,
        High = 4000,
        Dangerous = 8000,
        Cataclysmic = 16000,
        Max = 16500,
        ShowHighestWarningAsMax = true,
        ButtonPriority = 10,

        DisplayName = "Particles On Average",
        ShortName = "Particles/Avg",
        UseMeter = true
    },

    ParticlesOnAveragePerEmit = {
        ManualOrder = -9,
        High = 2000,
        Dangerous = 3000,
        Cataclysmic = 6000,
        Max = 8000,

        DisplayName = "Particles On Average Per Emit",
        ShortName = "Particles/Avg/Emit",
        UseMeter = true
    },

    ParticlesPerSecond = {
        ManualOrder = -8,
        Max = 10000,
        UseMeter = false,
        
        DisplayName = "Particles Per Second",
        ShortName = "Particles/Second"
    },

    ParticlesPerEmit = {
        ManualOrder = -7,
        DisplayName = "Particles/Emit",
        UseMeter = false
    }
}

Config.Optometer = {
    Data = OptometerData,
    MaxEmitRepeatCount = 10
}

Config.NodeFX = {
    GridSize = 24,
}

return Config