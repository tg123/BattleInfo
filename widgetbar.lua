local _, ADDONSELF = ...
local L = ADDONSELF.L
local RegEvent = ADDONSELF.regevent

local f = CreateFrame("Frame", nil, UIWidgetTopCenterContainerFrame)
f:SetAllPoints()


local spirittime

local function GetSpiritHealerText()
	if spirittime then
		c = 30015
		x = mod(c - mod((( GetTime() - spirittime)) * 1000, c), c) / 1000 + 1
		if x > 30 then
			return L["Spirit healing ..."]
        end
		return L["Spirit heal AE in: %s Secs"]:format(GREEN_FONT_COLOR:WrapTextInColorCode(floor(x)))
	else
		return L["Spirit heal AE: not dead"]
	end
end

local function UpdatepiritHealerText()
    if GetAreaSpiritHealerTime() > 0 then 
        spirittime = GetTime() + GetAreaSpiritHealerTime()
    end

    f.spiritlabel:SetText(GetSpiritHealerText())
end

local function IsInAlterac()
    local info = C_Map.GetMapInfo(1459)
    return GetRealZoneText() == info.name
end

local function HideAll()
    f:Hide()
end

local function ShowAll()
    f:Show()

    if IsInAlterac() then
        f.av:Show()
    else
        f.av:Hide()
    end
end

local function OnUpdate()
    if not ADDONSELF.InBattleground() then
        HideAll()
        return
    end

    ShowAll()
    UpdatepiritHealerText()

    f.elapselabel:SetText(SecondsToTime(GetBattlefieldInstanceRunTime()/1000))

    RequestBattlefieldScoreData()
end

-- RegEvent("PLAYER_ENTERING_WORLD", function()

-- end)

RegEvent("UPDATE_BATTLEFIELD_SCORE", function()

    local a = 0
    local h = 0
    
    local stat = {}
    stat[0] = {}
    stat[1] = {}

    for i = 1, 80 do
        local playerName, _, _, _, _, faction, _, _, _, filename = GetBattlefieldScore(i)
        if faction == 0 then
            a = a + 1
        elseif faction == 1 then
            h = h + 1
        end

        if not stat[faction][filename] then
            stat[faction][filename] = 0
        end

        stat[faction][filename] = stat[faction][filename] + 1
        -- print(faction)
        -- local playerName = GetBattlefieldScore(i);
    end

    f.num.alliance:SetText(a)
    f.num.horde:SetText(h)
    f.num.stat = stat
end)

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
        local av = CreateFrame("Frame", nil, f)
        av:SetAllPoints()
        f.av = av

        do
            local t = av:CreateTexture(nil, "BACKGROUND")
            t:SetAtlas("alliance_icon_horde_flag-icon")
            t:SetWidth(42)
            t:SetHeight(42)
            t:SetPoint("TOP", av, "TOP", -3, 0)

            local l = av:CreateFontString(nil, "BACKGROUND", "GameFontNormalSmall")
            l:SetPoint("TOP", t, "TOP", 30, -5)
            l:SetText(C_CreatureInfo.GetFactionInfo(1).name)
        end

        do
            local t = av:CreateTexture(nil, "BACKGROUND")
            t:SetAtlas("horde_icon_alliance_flag-icon")
            t:SetWidth(42)
            t:SetHeight(42)
            t:SetPoint("TOP", av, "TOP", -3, -25)

            local l = av:CreateFontString(nil, "BACKGROUND", "GameFontNormalSmall")
            l:SetPoint("TOP", t, "TOP", 30, -5)
            l:SetText(C_CreatureInfo.GetFactionInfo(2).name)       
        end
    end

    do

        local l = f:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
        l:SetPoint("TOPLEFT", f, -15, 12)
        f.spiritlabel = l

    end


    do
        local num = CreateFrame("Frame", nil, f)
        num:SetSize(35, 42)
        num:SetPoint("TOPLEFT", f, -35, 0)

        num:SetScript("OnLeave", hideTooltip)
        f.num = num

        local tooltip = CreateFrame("GameTooltip", "BattleInfoNumber" .. random(10000), UIParent, "GameTooltipTemplate")

        local classLoc = {}
        FillLocalizedClassList(classLoc)

        local factionLoc = {}
        factionLoc[0] = C_CreatureInfo.GetFactionInfo(1).name
        factionLoc[1] = C_CreatureInfo.GetFactionInfo(2).name

        local showTooltip = function(faction)
            if not num.stat then
                return
            end
            tooltip:SetOwner(num, "ANCHOR_LEFT")
            tooltip:SetText(factionLoc[faction])
            tooltip:AddLine(" ")

            for c, n in pairs(num.stat[faction]) do
                local color = GetClassColorObj(c)
                tooltip:AddDoubleLine(color:WrapTextInColorCode(classLoc[c]), n)
            end

            tooltip:Show()
        end

        local hideTooltip = function()
            tooltip:Hide()
            tooltip:SetOwner(UIParent, "ANCHOR_NONE")
        end        

        do
            local t =  CreateFrame("Frame", nil, num)
            t:SetPoint("TOPLEFT", num, 0, -7)
            t:SetSize(35, 10)
            t:SetScript("OnEnter", function()
                showTooltip(0)
            end)
            t:SetScript("OnLeave", hideTooltip)


            local l = t:CreateFontString(nil, "ARTWORK", "GameFontNormal")
            l:SetPoint("TOPLEFT", num, 0, -7)
            f.num.alliance = l
            -- l:SetText("10")
        end

        do
            local t =  CreateFrame("Frame", nil, num)
            t:SetPoint("TOPLEFT", num, 0, -30)
            t:SetSize(35, 21)
            t:SetScript("OnEnter", function()
                showTooltip(1)
            end)
            t:SetScript("OnLeave", hideTooltip)

            local l = t:CreateFontString(nil, "ARTWORK", "GameFontNormal")
            l:SetPoint("TOPLEFT", num, 0, -30)
            f.num.horde = l
            -- l:SetText("20")
        end
    end

    do
        local l = f:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
        l:SetPoint("TOPLEFT", f, -15, -50)
        f.elapselabel = l
    end

    UIWidgetTopCenterContainerFrame:HookScript("OnUpdate", OnUpdate)
end)