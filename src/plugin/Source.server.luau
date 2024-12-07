--[[
    This script controls the main behavior of the plugin

    Most of the other behavior is controlled in each tool's module
]]

type MenuButtonPair = {
    Menu : any,
    Button : TextButton
}

--[[
    Initiation data
]]
local oa = script.Parent
local Utility = oa.Utility
local MainFrame = oa.MainFrame:Clone()
local Menus = oa.Menus
local Replicatables = oa.Replicatables

local BottomBar = MainFrame.BottomBar
local version = "V0.1 β"

local OALanguage = require(Utility.OALanguage)
local LocalText = require(Utility.LocalText)

local FlipToggle = require(Utility.Classes.FlipToggle)

local toolbar = plugin:CreateToolbar("Optimize Architect")
local openPluginButton = toolbar:CreateButton("openOA", "Opens the Optimize Architect plugin.", "http://www.roblox.com/asset/?id=78032664445396", "Open plugin")

local MenuButtons : {MenuButtonPair} = {}

local widgetInfo = DockWidgetPluginGuiInfo.new(
    Enum.InitialDockState.Left,
    false,
    false,
    470,
    430,
    270,
    300
)

local oaWidget = plugin:CreateDockWidgetPluginGui("Optimize Architect", widgetInfo)
MainFrame.Parent = oaWidget

local Language = OALanguage.English
LocalText.Language = Language

--[[
    Runtime methods
]]

local function RunFunctionSafe(func : () -> ())
    if (func) then
        return func()
    end

    return
end

local function SetupButtons()
    MenuButtons = table.create(0)

    for _, v in MainFrame.SidebarHolder.SidebarFrame:GetChildren() do
        if (v:IsA("UIPadding")) then continue end
        v:Destroy()
    end

    for _, v in Menus:GetChildren() do
        if not (v:IsA("ModuleScript")) then continue end
        local currentMenu = require(v)

        assert(currentMenu.MenuNameKey, "Menu missing MenuNameKey")

        local newButton = Replicatables.MenuButton:Clone()
        newButton.Parent = MainFrame.SidebarHolder.SidebarFrame
        newButton.Text = LocalText.GetLocalText(currentMenu.MenuNameKey)

        newButton.MouseButton1Click:Connect(function()
            RunFunctionSafe(currentMenu.OnCreation)
        end)

        table.insert(MenuButtons, {Menu = currentMenu, Button = newButton} :: MenuButtonPair)
    end
end

local function ReloadLanguage()
    LocalText.Language = Language

    oaWidget.Title = LocalText.GetLocalText("MenuTitle")
    BottomBar.Title.Text = LocalText.GetLocalText("PluginName").." "..version

    for _, v in MenuButtons do
        v.Button.Text = LocalText.GetLocalText(v.Menu.MenuNameKey)
    end
end

openPluginButton.Click:Connect(function()
    oaWidget.Enabled = not oaWidget.Enabled

    if (oaWidget.Enabled) then
        ReloadLanguage()
    end
end)

local languageToggle = FlipToggle.new(BottomBar.LanguageToggle, UDim2.new(0.5, -15, 0.5, 0), UDim2.new(0.5, 15, 0.5, 0), BottomBar.LanguageToggle.Mover, 0.15)
languageToggle:SetColors(Color3.fromRGB(190, 190, 207), Color3.new(1, 1, 1), Color3.fromRGB(190, 190, 207))
languageToggle:UpdateColor()

function languageToggle.OnToggled()
   Language = OALanguage.Korean
    ReloadLanguage()
end

function languageToggle.OnUntoggled()
    Language = OALanguage.English
    ReloadLanguage()
end

SetupButtons()