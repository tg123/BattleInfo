local _, ADDONSELF = ...
local L = ADDONSELF.L
local RegEvent = ADDONSELF.regevent

local function UpdateInstanceButtonText()

	for i = 1, BATTLEFIELD_ZONES_DISPLAYED, 1 do
        local button = getglobal("BattlefieldZone"..i)
        -- print(button:GetText())
    end
end

RegEvent("CHAT_MSG_ADDON", function(prefix, text, channel, sender)

end)


local battleList = {}
local function UpdateBattleListCache()
    local mapName = GetBattlegroundInfo()

    if not mapName then
        return
    end

    if not battleList[mapName] then
        battleList[mapName] = {}
    end
    table.wipe(battleList[mapName])
    
    local n = GetNumBattlefields()
    for i = 1, n  do
        local instanceID = GetBattlefieldInstanceInfo(i)
        battleList[mapName][tonumber(instanceID)] = i .. "/" .. n
    end

    UpdateInstanceButtonText()
end


RegEvent("ADDON_LOADED", function()
    C_ChatInfo.RegisterAddonMessagePrefix("BATTLEINFO")

    hooksecurefunc("JoinBattlefield", UpdateBattleListCache)
    hooksecurefunc("BattlefieldFrame_Update", UpdateBattleListCache)

    -- hooksecurefunc(StaticPopupDialogs["CONFIRM_BATTLEFIELD_ENTRY"], "OnShow", function(self)
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
                else
                    local text = GREEN_FONT_COLOR:WrapTextInColorCode(L["New"])
                    self.text:SetText(string.gsub(tx ,toJ , toJ .. "(" .. text .. ")"))

                end
                break
            end
        end
        
    end

end)