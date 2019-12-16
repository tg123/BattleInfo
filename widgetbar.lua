local _, ADDONSELF = ...
local L = ADDONSELF.L
local RegEvent = ADDONSELF.regevent

local spiritlabel
local spirittime

local function GetSpiritHealerText()
	if spirittime then
		c = 30015
		x = mod(c - mod((( GetTime() - spirittime)) * 1000, c), c) / 1000 + 1
		if x > 30 then
			return L["Spirit healing ..."]
        end
		return L["Spirit heal AE in: %s seconds"]:format(GREEN_FONT_COLOR:WrapTextInColorCode(floor(x)))
	else
		return L["Spirit heal AE: not dead"]
	end
end

local function UpdatepiritHealerText()
    if GetAreaSpiritHealerTime() > 0 then 
        spirittime = GetTime() + GetAreaSpiritHealerTime()
    end

    spiritlabel:SetText(GetSpiritHealerText())
end

local function IsInAlterac()
    local info = C_Map.GetMapInfo(1459)
    return GetRealZoneText() == info.name
end

local function HideAll()
    spiritlabel:Hide()
end

local function ShowAll()
    spiritlabel:Show()
end


local function OnUpdate()
    if not ADDONSELF.InBattleground() then
        HideAll()
        return
    end

    ShowAll()
    UpdatepiritHealerText()
end


RegEvent("ADDON_LOADED", function()

    -- do
    --     local setID = C_UIWidgetManager.GetTopCenterWidgetSetID();
    --     if setID then
    --         hooksecurefunc(UIWidgetManager.registeredWidgetSetContainers[setID], "layoutFunc", function()
    --             print(11)
    --         end)
    --     end
    -- end

    do
        local l = UIWidgetTopCenterContainerFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        l:SetPoint("TOPLEFT", UIWidgetTopCenterContainerFrame, -15, 12)
        spiritlabel = l
    end

    UIWidgetTopCenterContainerFrame:HookScript("OnUpdate", OnUpdate)
end)