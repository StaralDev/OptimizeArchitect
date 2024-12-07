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

local TestMenu = Menu.new("Name_TestMenu", true, MenuFrames.TestMenu)

--[[
    The OnCreation() method runs at the very moment you click the button that
    opens the menu but after the MenuFrame is cloned.
]]
function TestMenu.OnCreation() end

--[[
    The OnLanguageReload method runs right after OnCreation() and every time the language toggle is flipped.

    Don't let the massive type being passed through intimidate you,
    The typechecking is optional so you can do LocalText.GetLocalText() without
    typing all of that, but if you want to still have the typechecking it should
    auto complete.
]]
function TestMenu.OnLanguageReload(LocalText : { GetLocalText: (string) -> string, Language: number }) end

--[[
    The OnDeletion method runs when the tool is deleted. 
    
    Sometimes you may have a connection function that doesn't
    get automatically disconnected. This is a good place to do it.
]]
function TestMenu.OnDeletion() end

--[[
    The OnTick method runs every single frame and gives you the DeltaTime.
]]
function TestMenu.OnTick(DeltaTime : number) end

--[[
    Make sure to return the menu at the end of the module.
]]
return TestMenu