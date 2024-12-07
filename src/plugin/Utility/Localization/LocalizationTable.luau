--[[
    All of the localization data in the entire plugin
]]

local loc : { [string]: {[number]:string} } = {}

loc["Error"] = {
    "Error: Missing localization key",
    "오류: 현지화 키 누락"
}
loc["PluginName"] = {
    "Optimize Architect",
    "최적화된 아키텍처"
}
loc["MenuTitle"] = {
    "Select a tool",
    "도구 선택"
}
loc["Name_TestMenu"] = {
    "Test Menu",
    "테스트 메뉴"
}

return loc