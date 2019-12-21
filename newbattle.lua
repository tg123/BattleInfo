local _, ADDONSELF = ...
local L = ADDONSELF.L
local RegEvent = ADDONSELF.regevent
local BattleZoneHelper = ADDONSELF.BattleZoneHelper

local elapseCache = {}

local function GetElapseFromCache(nameOrId, instanceID)
    if BattleZoneHelper.BGID_MAPNAME_MAP[nameOrId] then
        nameOrId = BattleZoneHelper.BGID_MAPNAME_MAP[nameOrId]
    end

    local key = nameOrId .. "-" .. instanceID

    local data = elapseCache[key]

    if data then

        if GetServerTime() - data.time > 90 then -- data ttl 90sec (bg will close in 2 min)
            elapseCache[key] = nil
            return nil
        end

        return GetServerTime() - data.time + data.elapse
    end

    return nil
end

local function UpdateInstanceButtonText()
    local mapName, _, _, _, battleGroundID = GetBattlegroundInfo()

    if not mapName then
        return
    end

	for i = 1, BATTLEFIELD_ZONES_DISPLAYED, 1 do
        local button = getglobal("BattlefieldZone"..i)

        local tx = button.title;

        (function()
            if not tx then
                return
            end

            local _, _, instanceID = string.find(tx, mapName .. " (%d+)")

            if not instanceID then
                return
            end

            local elp = GetElapseFromCache(battleGroundID, instanceID)

            if elp then

                -- local start = data.time - data.elapse
                -- print(GetServerTime() - data.time)
                -- print(data.elapse)
                button:SetText(tx .. GREEN_FONT_COLOR:WrapTextInColorCode(" (" .. SecondsToTime(elp) .. ")"))
                -- print()
            end

        end)()


    end
end

RegEvent("CHAT_MSG_ADDON", function(prefix, text, channel, sender)
    if prefix ~= "BATTLEINFO" then
        return
    end

    sender = strsplit("-", sender)

    if sender == UnitName("player") then
        return
    end

    -- print(sender)
    -- print(text)
    local cmd, arg1, arg2, arg3 = strsplit(" ", text)

    if cmd == "ELAPSE_WANTED" then
        local battleGroundID, instanceID = BattleZoneHelper:GetCurrentBG()

        if battleGroundID and instanceID then
            local key = battleGroundID .. "-" .. instanceID
            local elapse = -1
            if not GetBattlefieldWinner() then
                elapse = floor(GetBattlefieldInstanceRunTime() / 1000)
            end
            C_ChatInfo.SendAddonMessage("BATTLEINFO", "ELAPSE_SYNC " .. key .. " " .. elapse .. " " .. GetServerTime(), "GUILD")
        end
    elseif cmd == "ELAPSE_SYNC" then

        local key = arg1
        local elapse = tonumber(arg2)
        local time = tonumber(arg3)

        if (not key) or (not elapse) or (not time) then
            return
        end
      
        if elapseCache[key] then
            if elapseCache[key].time > time then
                return
            end
        end

        if elapse < 0 then
            elapseCache[key] = nil
        else
            elapseCache[key] = {
                sender = sender,
                elapse = elapse,
                time = time,
            }
        end

        UpdateInstanceButtonText()
    end


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

RegEvent("BATTLEFIELDS_SHOW", function()
    C_ChatInfo.SendAddonMessage("BATTLEINFO", "ELAPSE_WANTED", "GUILD")
end)

RegEvent("ADDON_LOADED", function()
    C_ChatInfo.RegisterAddonMessagePrefix("BATTLEINFO")

    hooksecurefunc("JoinBattlefield", UpdateBattleListCache)
    hooksecurefunc("BattlefieldFrame_Update", UpdateBattleListCache)

    -- hooksecurefunc(StaticPopupDialogs["CONFIRM_BATTLEFIELD_ENTRY"], "OnShow", function(self)
    StaticPopupDialogs["CONFIRM_BATTLEFIELD_ENTRY"].OnShow = function(self)
        local tx = self.text:GetText()

        SendChatMessage(tx,"WHISPER",nil,UnitName("player"))
			
        if string.find(tx, L["List Position"], 1, 1) or string.find(tx, L["New"], 1 , 1) then			
            return
        end    

        for mapName, instanceIDs in pairs(battleList) do
            local _, _ ,toJ = string.find(tx, ".+" .. mapName .. " (%d+).+")
            toJ = tonumber(toJ)
            if toJ then
                if instanceIDs[toJ] then
                    local text = L["List Position"] .. " " .. instanceIDs[toJ]

                    local elp = GetElapseFromCache(mapName, toJ)
                    if elp then
                        text = SecondsToTime(elp)
                    end

                    text = RED_FONT_COLOR:WrapTextInColorCode(text)

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
