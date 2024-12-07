--[[
    This menu is meant to show you how to make a menu

    Follow this if you want to make your own tool
]]

--[[
    These are some of the variables you need
]]
local Menus = script.Parent
local oa = Menus.Parent
local MenuFrames = oa.MenuFrames

local Utility = oa.Utility
local Menu = require(Utility.Classes.Menu)

local TestMenu = Menu.new(
    "Name_TestMenu", -- The menuNameKey will be used in the LocalizationTable.luau to find the name coresponding to the language
    true, -- Weither this tool should appear
    MenuFrames.TestMenu, -- The gui to clone when the menu is opened
    {TestProperty = 1} -- A table of custom properties (better than global variables!)
)

--[[
    The OnCreation() method runs at the very moment you click the button that
    opens the menu but after the MenuFrame is cloned.
]]
function TestMenu.OnCreation(MyMenu : typeof(MenuFrames.TestMenu)) 
    print(TestMenu.TestProperty) -- You won't get autocomplete for these, but they are still accessable
end

--[[
    The OnLanguageReload method runs right after OnCreation() and every time the language toggle is flipped.
]]
function TestMenu.OnLanguageReload(MyMenu : typeof(MenuFrames.TestMenu)) end

--[[
    The OnDeletion method runs when the tool is deleted. 
    
    Sometimes you may have a connection function that doesn't
    get automatically disconnected. This is a good place to do it.

    This module never gets deleted or duplicated so this is a good 
    place to discard data you don't need in the future
]]
function TestMenu.OnDeletion(MyMenu : typeof(MenuFrames.TestMenu)) end

--[[
    The OnTick method runs every single frame and gives you the DeltaTime.
]]
function TestMenu.OnTick(MyMenu : typeof(MenuFrames.TestMenu), DeltaTime : number) end

--[[
    Make sure to return the menu at the end of the module.
]]
return TestMenu