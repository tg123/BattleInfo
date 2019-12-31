local _, ADDONSELF = ...
local L = ADDONSELF.L
local RegEvent = ADDONSELF.regevent

RegEvent("ADDON_LOADED", function()
    if not BatteInfoSettings then
        BatteInfoSettings = {}
    end
end)

local defs = {}
local function GetConfigOrDefault(key, def)
    defs[key] = def

    local config = BatteInfoSettings

    if config[key] == nil then
        config[key] = def
    end

    return config[key]
end

local changedcb = {}
local function RegisterKeyChangedCallback(key, cb)
    if not changedcb[key] then
        changedcb[key] = {}
    end

    table.insert(changedcb[key] , cb)
end
ADDONSELF.RegisterKeyChangedCallback = RegisterKeyChangedCallback

local function triggerCallback(key, value)
    for _, cb in pairs(changedcb[key] or {}) do
        cb(value)
    end
end

local function SetConfig(key, value)
    BatteInfoSettings[key] = value

    triggerCallback(key, value)
end


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

local function createCheckbox(title, key, def)
    local b = CreateFrame("CheckButton", nil, f, "UICheckButtonTemplate")
    b.text = b:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    b.text:SetPoint("LEFT", b, "RIGHT", 0, 1)
    b.text:SetText(title)
    b:SetScript("OnClick", function()
        SetConfig(key, b:GetChecked())
    end)

    RegisterKeyChangedCallback(key, function(v)
        b:SetChecked(v)
    end)

    triggerCallback(key, GetConfigOrDefault(key, def))
    return b
end

RegEvent("PLAYER_LOGIN", function()

    f.default = function()
        for k, v in pairs(defs) do
            SetConfig(k, v)
        end
    end

    f.refresh = function()
    end

    do
        local b = createCheckbox(L["Replace"] .. " " .. ENTER_BATTLE, "replace_enter_battle", false)
        b:SetPoint("TOPLEFT", f, 15, -80)
    end

    do
        local b = createCheckbox(L["Show Spirit heal AE Timer"], "show_spirit_heal", true)
        b:SetPoint("TOPLEFT", f, 15, -110)
    end

    do
        local b = createCheckbox(L["Show Battleground time elapsed"], "show_time_elapsed", true)
        b:SetPoint("TOPLEFT", f, 15, -140)
    end

end)