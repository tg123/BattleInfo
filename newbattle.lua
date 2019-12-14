local _, ADDONSELF = ...

local L = ADDONSELF.L

local battleList = {}
local battleListOld = {}

local function CloneToOld(map)
    if not battleListOld[map] then
        battleListOld[map] = {}
    end

    table.wipe(battleListOld[map])

    for instanceID in pairs(battleList[map] or {})  do
        battleListOld[map][instanceID] = true
	end
end

local function UpdateBattleListCache()
    local mapName = GetBattlegroundInfo()

    if not mapName then
        return
    end

    CloneToOld(mapName)

    if not battleList[mapName] then
        battleList[mapName] = {}
    end
    table.wipe(battleList[mapName])
    
    for i = 1, GetNumBattlefields()  do
        local instanceID = GetBattlefieldInstanceInfo(i)
        battleList[mapName][tonumber(instanceID)] = true
	end
end

hooksecurefunc("JoinBattlefield", UpdateBattleListCache)
hooksecurefunc("BattlefieldFrame_Update", UpdateBattleListCache)

StaticPopupDialogs["CONFIRM_BATTLEFIELD_ENTRY"].OnShow = function(self)
    local tx = self.text:GetText()

    if string.find(tx, L["Old"], 1, 1) or string.find(tx, L["New"], 1 , 1) or string.find(tx, L["Perhaps"], 1, 1) then			
        return
    end    

    for mapName, instanceIDs in pairs(battleList) do
        local _, _ ,toJ = string.find(tx, ".+" .. mapName .. " (%d+).+")
        toJ = tonumber(toJ)
        if toJ then
            if instanceIDs[toJ] then
                local colorCode = RED_FONT_COLOR:GenerateHexColor()
                local text = WrapTextInColorCode(L["Old"], colorCode)
                self.text:SetText(string.gsub(tx ,toJ , toJ .. "(" .. text .. ")"))

            elseif battleListOld[mapName][toJ] then
                local colorCode = YELLOW_FONT_COLOR:GenerateHexColor()
                local text = WrapTextInColorCode(L["Perhaps"], colorCode)
                self.text:SetText(string.gsub(tx ,toJ , toJ .. "(" .. text .. ")"))

            else
                local colorCode = GREEN_FONT_COLOR:GenerateHexColor()
                local text = WrapTextInColorCode(L["New"], colorCode)
                self.text:SetText(string.gsub(tx ,toJ , toJ .. "(" .. text .. ")"))

            end
            break
        end
    end
	
end