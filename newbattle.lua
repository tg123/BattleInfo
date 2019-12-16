local _, ADDONSELF = ...

local L = ADDONSELF.L

local battleList = {}
-- local battleListOld = {}

-- local function CloneToOld(map)
--     if not battleListOld[map] then
--         battleListOld[map] = {}
--     end

--     table.wipe(battleListOld[map])

--     for instanceID in pairs(battleList[map] or {})  do
--         battleListOld[map][instanceID] = true
-- 	end
-- end

local function UpdateBattleListCache()
    local mapName = GetBattlegroundInfo()

    if not mapName then
        return
    end

    -- CloneToOld(mapName)

    if not battleList[mapName] then
        battleList[mapName] = {}
    end
    table.wipe(battleList[mapName])
    
    local n = GetNumBattlefields()
    for i = 1, n  do
        local instanceID = GetBattlefieldInstanceInfo(i)
        battleList[mapName][tonumber(instanceID)] = i .. "/" .. n
	end
end

hooksecurefunc("JoinBattlefield", UpdateBattleListCache)
hooksecurefunc("BattlefieldFrame_Update", UpdateBattleListCache)

-- SecondsToTime(GetBattlefieldInstanceRunTime()/1000)

StaticPopupDialogs["CONFIRM_BATTLEFIELD_ENTRY"].OnShow = function(self)
    local tx = self.text:GetText()

    if string.find(tx, L["List Position"], 1, 1) or string.find(tx, L["New"], 1 , 1) then			
        return
    end    

    for mapName, instanceIDs in pairs(battleList) do
        local _, _ ,toJ = string.find(tx, ".+" .. mapName .. " (%d+).+")
        toJ = tonumber(toJ)
        if toJ then
            if instanceIDs[toJ] then
                local text = RED_FONT_COLOR:WrapTextInColorCode(L["List Position"] .. " " .. instanceIDs[toJ])
                self.text:SetText(string.gsub(tx ,toJ , toJ .. "(" .. text .. ")"))

            -- elseif battleListOld[mapName][toJ] then
            --     local text = YELLOW_FONT_COLOR:WrapTextInColorCode(L["Perhaps"] .. " " .. battleListOld[mapName][toJ])
            --     self.text:SetText(string.gsub(tx ,toJ , toJ .. "(" .. text .. ")"))

            else
                local text = GREEN_FONT_COLOR:WrapTextInColorCode(L["New"])
                self.text:SetText(string.gsub(tx ,toJ , toJ .. "(" .. text .. ")"))

            end
            break
        end
    end
	
end