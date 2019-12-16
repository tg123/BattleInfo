local _, ADDONSELF = ...
local L = ADDONSELF.L
local RegEvent = ADDONSELF.regevent


ADDONSELF.Print = function(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|CFFFF0000<|r|CFFFFD100BattleInfo|r|CFFFF0000>|r"..(msg or "nil"))
end

ADDONSELF.InBattleground = function()
    -- return true
    return UnitInBattleground("player")
end

RegEvent("ADDON_LOADED", function()
    ADDONSELF.Print(L["BatteInfo Loaded"])
end)