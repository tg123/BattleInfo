local _, ADDONSELF = ...

local L = ADDONSELF.L

local battleList = {}
local battleListOld = {}

local function CloneToOld(map)
    battleListOld[map] = {}

    for instanceID in pairs(battleList[map] or {})  do
        battleListOld[map][instanceID] = true
	end
end

local function UpdateBattleListCache()
    -- print(1)
    local b = GetBattlegroundInfo()
    local mapName = GetBattlegroundInfo()

    CloneToOld(mapName)
    battleList[mapName] = {}
    for i = 1, GetNumBattlefields()  do
        local instanceID = GetBattlefieldInstanceInfo(i)
        battleList[mapName][tonumber(instanceID)] = true
	end
end


hooksecurefunc("JoinBattlefield", function()
    UpdateBattleListCache()
end)

StaticPopupDialogs["CONFIRM_BATTLEFIELD_ENTRY"].OnShow = function(self)
    local tx = self.text:GetText()

    if string.find(tx, L["OLD"], 1, 1) or string.find(tx, L["NEW"], 1 , 1) or string.find(tx, L["PERHAPS"], 1, 1) then			
        return
    end    

    for mapName, instanceIDs in pairs(battleList) do
        local _, _ ,toJ = string.find(tx, ".+" .. mapName .. " (%d+).+")
        toJ = tonumber(toJ)
        if toJ then
            if instanceIDs[toJ] then
                local colorCode = RED_FONT_COLOR:GenerateHexColor()
                local text = WrapTextInColorCode(L["OLD"], colorCode)
                self.text:SetText(string.gsub(tx ,toJ , toJ .. "(" .. text .. ")"))

            elseif battleListOld[mapName][toJ] then
                local colorCode = YELLOW_FONT_COLOR:GenerateHexColor()
                local text = WrapTextInColorCode(L["PERHAPS"], colorCode)
                self.text:SetText(string.gsub(tx ,toJ , toJ .. "(" .. text .. ")"))

            else
                local colorCode = GREEN_FONT_COLOR:GenerateHexColor()
                local text = WrapTextInColorCode(L["NEW"], colorCode)
                self.text:SetText(string.gsub(tx ,toJ , toJ .. "(" .. text .. ")"))

            end
            break
        end
    end
	
end