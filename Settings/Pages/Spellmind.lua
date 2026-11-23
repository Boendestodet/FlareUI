-- Spellmind integration scaffold for FlareUI.
-- Native FlareUI settings page: no reparenting, no legacy Spellmind windows.
-- This page deliberately does not send AI prompts until the Spellmind bridge is ported.
local _, ns = ...
local S = ns.Settings
local P = ns.SettingsPanel

local GOLD = {1, 0.82, 0.25}
local MUTED = {0.67, 0.62, 0.55}
local EDGE = {0.65, 0.49, 0.27}
local bg = {bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = false, edgeSize = 12, insets = {left = 4, right = 4, top = 4, bottom = 4}}

local function Label(parent, text, x, y, font, width)
    local t = parent:CreateFontString(nil, "OVERLAY", font or "GameFontHighlight")
    t:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    if width then t:SetWidth(width); t:SetJustifyH("LEFT"); t:SetWordWrap(true) end
    t:SetText(text)
    return t
end

local function Box(parent, x, y, w, h)
    local b = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    b:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    b:SetSize(w, h)
    b:SetBackdrop(bg)
    b:SetBackdropColor(0.055, 0.045, 0.034, 0.98)
    b:SetBackdropBorderColor(unpack(EDGE))
    return b
end

local function Button(parent, text, x, y, w, callback)
    local b = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    b:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    b:SetSize(w, 26)
    b:SetText(text)
    if ns.SkinButton then ns.SkinButton(b) end
    b:SetScript("OnClick", callback)
    return b
end

local function CharacterText()
    local level = UnitLevel and UnitLevel("player") or "?"
    local name = UnitName and UnitName("player") or "Unknown"
    local class = UnitClass and UnitClass("player") or "Unknown"
    local zone = GetZoneText and GetZoneText() or "Unknown"
    return ("Character: %s\nLevel: %s\nClass: %s\nZone: %s"):format(
        tostring(name or "?"), tostring(level or "?"),
        tostring(class or "?"), tostring(zone or "?"))
end

local function QuestText()
    local count = 0
    if C_QuestLog and C_QuestLog.GetNumQuestLogEntries then
        local ok, n = pcall(C_QuestLog.GetNumQuestLogEntries)
        if ok and type(n) == "number" then count = n end
    elseif GetNumQuestLogEntries then
        local ok, n = pcall(GetNumQuestLogEntries)
        if ok and type(n) == "number" then count = n end
    end
    return ("Quest log entries: %d\n\nThis is a read-only preview. Quest recommendations and routes will connect after the Spellmind data modules are ported."):format(count)
end

local function NativePage(host, section)
    local width = (P.MIDDLE_W or 630) - 8
    local top = Box(host, 4, -4, width, 142)
    local header = Label(top, "Spellmind AI", 16, -14, "GameFontNormalLarge", width - 32)
    header:SetTextColor(unpack(GOLD))
    local detail = Label(top, "", 16, -50, "GameFontHighlight", width - 32)
    local lower = Box(host, 4, -158, width, 278)
    local title = Label(lower, section, 16, -14, "GameFontNormalLarge", width - 32)
    title:SetTextColor(unpack(GOLD))
    local body = Label(lower, "", 16, -53, "GameFontHighlight", width - 32)
    local function Refresh()
        local loaded = C_AddOns and C_AddOns.IsAddOnLoaded and C_AddOns.IsAddOnLoaded("Spellmind")
        detail:SetText(
            "Native FlareUI panel | WoW Forever 1.60.1\n" ..
            "Spellmind addon: " .. (loaded and "loaded" or "not loaded") ..
            "\nAI bridge: not connected yet (no messages will be sent)"
        )
        if section == "Overview" then
            body:SetText("This page is built inside FlareUI's own settings panel. It does not open or overlay the old Spellmind interface.\n\nNext integration stage: port Spellmind's data and AI bridge into native FlareUI modules.")
        elseif section == "Character" then
            body:SetText(CharacterText())
        elseif section == "Quests" then
            body:SetText(QuestText())
        else
            body:SetText("The chat view is being rebuilt natively.\n\nSending messages is intentionally disabled until the existing Spellmind protocol is integrated and tested. No dummy AI calls or background windows.")
        end
    end
    Button(lower, "Refresh", 16, -221, 106, Refresh)
    host:HookScript("OnShow", Refresh)
    Refresh()
end

ns.Copy.modules.spellmind = {
    title = "Spellmind AI",
    desc = "AI companion integration, built directly into FlareUI.",
    tabs = {"Overview", "Character", "Quests", "AI Chat"}
}

S:Module{
    key = "spellmind",
    group = "interface",
    order = 45,
    navIcon = "Interface\\AddOns\\FlareUI\\Media\\Panel\\Icons\\about.tga",
    tabs = {
        { key = "overview", label = "Overview", custom = function(host) NativePage(host, "Overview") end },
        { key = "character", label = "Character", custom = function(host) NativePage(host, "Character") end },
        { key = "quests", label = "Quests", custom = function(host) NativePage(host, "Quests") end },
        { key = "chat", label = "AI Chat", custom = function(host) NativePage(host, "AI Chat") end },
    }
}
