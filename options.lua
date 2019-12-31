local _, ADDONSELF = ...
local L = ADDONSELF.L

local f = CreateFrame("Frame", nil, UIParent)
f.name = L["BattleInfo"]
InterfaceOptions_AddCategory(f)

do
    local t = f:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    t:SetText(L["BattleInfo"])
    t:SetPoint("TOPLEFT", f, 15, -15)
end

do
    local t = f:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    t:SetText(L["Feedback"] .. "  farmer1992@gmail.com")
    t:SetPoint("TOPLEFT", f, 15, -50)
end
