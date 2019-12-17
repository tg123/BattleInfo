local _, ADDONSELF = ...
local L = ADDONSELF.L
local RegEvent = ADDONSELF.regevent

local f = CreateFrame("Frame", nil, UIWidgetTopCenterContainerFrame)
f:SetAllPoints()


local spirittime

local function GetSpiritHealerText()
	if spirittime then
		local c = 30015
		local x = mod(c - mod((( GetTime() - spirittime)) * 1000, c), c) / 1000 + 1
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

local MAPID_ALTERAC = 1459

local function IsInAlterac()
    local info = C_Map.GetMapInfo(MAPID_ALTERAC)
    return GetRealZoneText() == info.name
end

local function UpdateAlteracNumbers()

    -- Alliance Tower 10
    -- Alliance Graveyard 14
    -- Horde Tower 9
    -- Horde Graveyard 12
    
    if not IsInAlterac() then
        return
    end

    local data = {}

    local areaPOIs = C_AreaPoiInfo.GetAreaPOIForMap(MAPID_ALTERAC)
    local textures = C_Map.GetMapArtLayerTextures(MAPID_ALTERAC, 1) -- 1 for layer id, should be a const value

	for _, areaPoiID in ipairs(areaPOIs) do
		local poiInfo = C_AreaPoiInfo.GetAreaPOIInfo(MAPID_ALTERAC, areaPoiID)
        if poiInfo then
            -- print(poiInfo.name)
            -- print(poiInfo.description)
            -- print(poiInfo.textureIndex)
            local t = poiInfo.textureIndex

            if not data[t] then
                data[t] = 0
            end

            data[t] = data[t] + 1
		end
    end
    
    for t, n in pairs(data) do
        if f.av.nums[t] then
            f.av.nums[t]:SetText(n)
        end
    end
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
    UpdateAlteracNumbers()
end

-- RegEvent("PLAYER_ENTERING_WORLD", function()

-- end)

local FACTION_HORDE = 0
local FACTION_ALLIANCE = 1

RegEvent("UPDATE_BATTLEFIELD_SCORE", function()

    local a = 0
    local h = 0
    
    local stat = {}
    stat[0] = {}
    stat[1] = {}

    for i = 1, 80 do
        local playerName, _, _, _, _, faction, _, _, _, filename = GetBattlefieldScore(i)
        if faction == FACTION_ALLIANCE then
            a = a + 1
        elseif faction == FACTION_HORDE then
            h = h + 1
        end

        if filename then
            if not stat[faction][filename] then
                stat[faction][filename] = 0
            end

            stat[faction][filename] = stat[faction][filename] + 1
        end
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

        av.nums = {}

        do
            local t = av:CreateTexture(nil, "BACKGROUND")
            t:SetAtlas("alliance_icon_horde_flag-icon")
            t:SetWidth(42)
            t:SetHeight(42)
            t:SetPoint("TOP", av, "TOP", -3, 0)

        end

        do
            local t = av:CreateTexture(nil, "BACKGROUND")
            t:SetPoint("TOP", av, "TOP", 15, -5)
            t:SetWidth(16);
            t:SetHeight(16);
            t:SetTexture("Interface/Minimap/POIIcons");
            
            local x1, x2, y1, y2 = GetPOITextureCoords(10) -- Alliance Tower
            t:SetTexCoord(x1, x2, y1, y2);

            local l = av:CreateFontString(nil, "BACKGROUND", "GameFontNormalSmall")
            l:SetPoint("TOPLEFT", t, "TOPLEFT", 20, -3)
            l:SetText("?")
            av.nums[10] = l
        end

        do
            local t = av:CreateTexture(nil, "BACKGROUND")
            t:SetPoint("TOP", av, "TOP", 50, -5)
            t:SetWidth(16);
            t:SetHeight(16);
            t:SetTexture("Interface/Minimap/POIIcons");
            
            local x1, x2, y1, y2 = GetPOITextureCoords(14) -- Alliance Graveyard 
            t:SetTexCoord(x1, x2, y1, y2);

            local l = av:CreateFontString(nil, "BACKGROUND", "GameFontNormalSmall")
            l:SetPoint("TOPLEFT", t, "TOPLEFT", 20, -3)
            l:SetText("?")
            av.nums[14] = l
        end

        do
            local t = av:CreateTexture(nil, "BACKGROUND")
            t:SetAtlas("horde_icon_alliance_flag-icon")
            t:SetWidth(42)
            t:SetHeight(42)
            t:SetPoint("TOP", av, "TOP", -3, -25)

            -- local l = av:CreateFontString(nil, "BACKGROUND", "GameFontNormalSmall")
            -- l:SetPoint("TOPLEFT", t, "TOPLEFT", 30, -5)
            -- l:SetText(C_CreatureInfo.GetFactionInfo(2).name)       
        end

        do
            local t = av:CreateTexture(nil, "BACKGROUND")
            t:SetPoint("TOP", av, "TOP", 15, -27)
            t:SetWidth(16);
            t:SetHeight(16);
            t:SetTexture("Interface/Minimap/POIIcons");
            
            local x1, x2, y1, y2 = GetPOITextureCoords(9) -- Horde Tower
            t:SetTexCoord(x1, x2, y1, y2);

            local l = av:CreateFontString(nil, "BACKGROUND", "GameFontNormalSmall")
            l:SetPoint("TOPLEFT", t, "TOPLEFT", 20, -3)
            l:SetText("?")
            av.nums[9] = l
        end

        do
            local t = av:CreateTexture(nil, "BACKGROUND")
            t:SetPoint("TOP", av, "TOP", 50, -27)
            t:SetWidth(16);
            t:SetHeight(16);
            t:SetTexture("Interface/Minimap/POIIcons");
            
            local x1, x2, y1, y2 = GetPOITextureCoords(12) -- Horde Graveyard 
            t:SetTexCoord(x1, x2, y1, y2);

            local l = av:CreateFontString(nil, "BACKGROUND", "GameFontNormalSmall")
            l:SetPoint("TOPLEFT", t, "TOPLEFT", 20, -3)
            l:SetText("?")
            av.nums[12] = l
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
        factionLoc[FACTION_ALLIANCE] = C_CreatureInfo.GetFactionInfo(1).name
        factionLoc[FACTION_HORDE] = C_CreatureInfo.GetFactionInfo(2).name

        local showTooltip = function(faction)
            if not num.stat then
                return
            end
            if #num.stat == 0 then
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
                showTooltip(FACTION_ALLIANCE)
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
                showTooltip(FACTION_HORDE)
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