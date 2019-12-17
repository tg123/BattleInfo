local _, ADDONSELF = ...
local L = ADDONSELF.L
local RegEvent = ADDONSELF.regevent


SlashCmdList["BATTLEINFO"] = function(msg, editbox)
    local cmd, what = msg:match("^(%S*)%s*(%S*)%s*$")

    if cmd == "" then
    elseif cmd == "reset" then
        UIWidgetTopCenterContainerFrame:SetUserPlaced(false)
        C_UI.Reload()
    end

end
SLASH_BATTLEINFO1 = "/BI"
