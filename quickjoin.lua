local _, ADDONSELF = ...
local L = ADDONSELF.L
local RegEvent = ADDONSELF.regevent

-- ADDONSELF.Print = function(msg)
--     DEFAULT_CHAT_FRAME:AddMessage("|CFFFF0000<|r|CFFFFD100RaidLedger|r|CFFFF0000>|r"..(msg or "nil"))
-- end


RegEvent("ADDON_LOADED", function()
    do

        local toidx = function(txt)
            local n = tonumber(txt)
            if n == 0 then
                return 0
            end
            for i = 1, GetNumBattlefields()  do
                local instanceID = GetBattlefieldInstanceInfo(i)
                if n == instanceID then
                    return i
                end
            end

            return nil
        end

        local t = CreateFrame("EditBox", nil, BattlefieldFrame, "InputBoxTemplate")
        t:SetWidth(50)
        t:SetHeight(25)
        t:SetPoint("BOTTOMRIGHT", BattlefieldFrame, -50, 100)
        t:SetAutoFocus(true)
        t:SetMaxLetters(6)
        t:SetNumeric(true)
        t:SetScript("OnTextChanged", function()
            local n = t:GetText()

            if n == "" then
                return
            end

            local mapName = GetBattlegroundInfo()
            local b = mapName .. " " .. n

            GameTooltip:SetOwner(t, "ANCHOR_TOP")

            local idx = toidx(n)
            if idx then
                FauxScrollFrame_SetOffset(BattlefieldListScrollFrame, idx)
                SetSelectedBattlefield(idx)
                BattlefieldFrame_Update()
            else
                b = RED_FONT_COLOR:WrapTextInColorCode(b)

                GameTooltip:SetText(L["Cannot find battleground %s"]:format(b))
            end

            GameTooltip:Show()
        end)
        -- t:SetScript("OnEnterPressed", function()
        --     local idx = toidx(t:GetText())
            
        --     if idx then
        --         BattlefieldFrameJoinButton_OnClick()
        --     end
        -- end)
        t:SetScript("OnShow", function() 
            t:SetText("0")
        end)
        t:SetScript("OnEscapePressed", function() HideUIPanel(BattlefieldFrame) end)

        local l = t:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        l:SetPoint("TOPLEFT", t, -100, -5)
        l:SetText(L["Quick select"])

    end



end) 