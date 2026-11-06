-------------------------------------------------------------------------------
--  LootFilter Forever: when loot opens, takes only what is wanted and closes the window.
--
--  Always takes: money and currencies, quest items, bags and keys,
--  items on the "always" list. Then, by settings:
--    * quality from a threshold (uncommon and above by default);
--    * profession materials;
--    * items that sell to a vendor for at least a threshold per unit;
--    * items that fit into a partial stack already in the bags and need
--      no new slot.
--  The rest stays on the corpse, and chat says exactly what.
--
--  Works with the game's Auto Loot off (the addon turns it off itself).
--  Shift while looting: take everything, like normal Auto Loot.
--  Ctrl while looting: just open the window, touching nothing.
--  Settings: /lootfilter (window) or Esc → Options → AddOns → LootFilter Forever.
-------------------------------------------------------------------------------
local RU = {
    ["Poor"] = "Серые",
    ["Common"] = "Белые",
    ["Uncommon"] = "Зелёные",
    ["Rare"] = "Синие",
    ["Epic"] = "Фиолетовые",
    ["poor"] = "серые",
    ["common"] = "белые",
    ["uncommon"] = "зелёные",
    ["rare"] = "синие",
    ["epic"] = "фиолетовые",
    ["left on the corpse: %s"] = "оставлено: %s",
    ["turned off the game's Auto Loot: I filter your loot now. Shift while looting: take everything; Ctrl: open the window as is. Settings: /lootfilter"] =
        "выключил автосбор игры: теперь добычу фильтрую я. Shift при сборе: взять всё; Ctrl: открыть окно как есть. Настройки: /lootfilter",
    ["the old LootSieve is installed too: delete the Interface/AddOns/LootSieve folder."] =
        "установлен и старый LootSieve: удали папку Interface/AddOns/LootSieve.",
    ["EllesmereUI Quick Loot is on: it takes everything. Turn it off in the EllesmereUI options (/eui)."] =
        "в EllesmereUI включён «Быстрый сбор»: он забирает всё подряд. Выключи его: /eui → Удобства → Быстрый сбор.",
    ["per unit"] = "за штуку",
    ["Filter enabled"] = "Фильтр включён",
    ["When off, the game's normal Auto Loot works."] = "Выключено: работает обычный автосбор игры.",
    ["Quality"] = "Качество",
    ["Always take items of this quality and above."] = "Всегда брать предметы этого качества и выше.",
    ["Vendor price"] = "Цена у торговца",
    ["Take low-quality items with a high vendor price"] = "Брать дешёвые по качеству, но дорогие предметы",
    ["For example, a grey goblet that sells for 80 silver. The threshold is per unit, not per stack."] =
        "Например, серый кубок за 80 серебра. Порог считается за одну штуку, не за всю пачку.",
    ["0 in every field: take everything that sells."] = "0 во всех полях: брать всё, что продаётся.",
    ["Also take"] = "Что ещё брать",
    ["Profession materials"] = "Материалы профессий",
    ["Ore, herbs, cloth, leather, meat, gems, recipes."] = "Руда, травы, ткань, кожа, мясо, самоцветы, рецепты.",
    ["Fill partial stacks in the bags"] = "Добирать в начатые стопки в сумке",
    ["If the item is already in your bags and its stack has room, it needs no new slot, so it is taken."] =
        "Если такой предмет уже лежит в сумке и в стопке есть место, он не займёт новый слот, и его можно взять.",
    ["Loot window"] = "Окно добычи",
    ["Close the window when the wanted loot is taken"] = "Закрывать окно, когда нужное собрано",
    ["The rest can be taken later: Shift while looting takes everything."] =
        "Оставшееся на трупе можно забрать позже: Shift при сборе берёт всё.",
    ["Report in chat what was left on the corpse"] = "Писать в чат, что осталось на трупе",
    ["Lists"] = "Списки",
    ["Clear"] = "Очистить",
    ["Always take: %d, never take: %d.\n/lootfilter add [item], /lootfilter ignore [item]"] =
        "Всегда брать: %d, никогда: %d.\n/lootfilter add [предмет], /lootfilter ignore [предмет]",
    ["Shift while looting: take everything.   Ctrl: open the loot window as is."] =
        "Shift при сборе: взять всё.   Ctrl: открыть окно добычи как есть.",
    ["Open LootFilter settings"] = "Открыть настройки LootFilter",
    ["money"] = "деньги",
    ["quest items"] = "квестовое",
    ["%s and above"] = "%s и выше",
    ["profession materials"] = "материалы профессий",
    ["anything worth %s or more per unit"] = "всё от %s за штуку",
    ["items that fit into partial stacks"] = "то, что ляжет в начатые стопки",
    ["enabled"] = "включён",
    ["disabled"] = "выключен",
    ["%s. Takes: %s."] = "%s. Берёт: %s.",
    ["/lootfilter: settings window; /lootfilter on | off: enable or disable"] =
        "/lootfilter: окно настроек; /lootfilter on | off: включить или выключить",
    ["/lootfilter quality 0-4: minimum quality (0 poor, 1 common, 2 uncommon, 3 rare, 4 epic)"] =
        "/lootfilter quality 0-4: порог качества (0 серые, 1 белые, 2 зелёные, 3 синие, 4 фиолетовые)",
    ["/lootfilter value N: per-unit price threshold in silver (0.05 = 5 copper)"] =
        "/lootfilter value N: порог цены за штуку в серебре (0.05 = 5 меди)",
    ["/lootfilter add [item]: always take; /lootfilter ignore [item]: never take"] =
        "/lootfilter add [предмет]: всегда брать; /lootfilter ignore [предмет]: никогда не брать",
    ["/lootfilter forget [item]: remove from the lists; /lootfilter list: show the lists"] =
        "/lootfilter forget [предмет]: убрать из списков; /lootfilter list: показать списки",
    ["take by quality: %s and above"] = "брать по качеству: %s и выше",
    ["need a number from 0 to 4, for example: /lootfilter quality 2"] = "нужно число от 0 до 4, например: /lootfilter quality 2",
    ["take everything worth %s or more per unit"] = "брать всё, что стоит от %s за штуку",
    ["need a number in silver, for example: /lootfilter value 10"] = "нужно число в серебре, например: /lootfilter value 10",
    ["paste an item link (Shift-click) or its ID"] = "вставь ссылку на предмет (Shift+клик) или его ID",
    ["always take: %s"] = "всегда брать: %s",
    ["never take: %s"] = "никогда не брать: %s",
    ["removed from the lists: %s"] = "убран из списков: %s",
    ["empty"] = "пусто",
}
local L = setmetatable(GetLocale() == "ruRU" and RU or {}, { __index = function(_, key) return key end })

local DEFAULTS = {
    enabled    = true,
    minQuality = 2,     -- 0 poor, 1 common, 2 uncommon, 3 rare, 4 epic
    useValue   = true,  -- take items below the quality threshold if they sell well
    unitPrice  = 1000,  -- copper PER UNIT: 1000 = 10 silver
    mats       = true,  -- profession materials, gems, recipes
    stack      = true,  -- fill partial stacks in the bags
    close      = true,  -- close the window once the wanted loot is taken
    report     = true,  -- report in chat what was left on the corpse
}

local LT = Enum.LootSlotType or {}
local SLOT_ITEM     = LT.Item or 1
local SLOT_MONEY    = LT.Money or 2
local SLOT_CURRENCY = LT.Currency or 3

local IC = Enum.ItemClass or {}
local ALWAYS_CLASS = {
    [IC.Questitem or 12] = true,
    [IC.Container or 1]  = true,
    [IC.Key or 13]       = true,
}
local MATS_CLASS = {
    [IC.Tradegoods or 7] = true,
    [IC.Recipe or 9]     = true,
    [IC.Gem or 3]        = true,
    [IC.Reagent or 5]    = true,
}

local QUALITY_NAMES = { [0] = L["Poor"], L["Common"], L["Uncommon"], L["Rare"], L["Epic"] }
local QUALITY_LOWER = { [0] = L["poor"], L["common"], L["uncommon"], L["rare"], L["epic"] }  -- string.lower does not case Cyrillic
local MAX_QUALITY = 4
local LAST_BAG = NUM_TOTAL_EQUIPPED_BAG_SLOTS or NUM_BAG_SLOTS or 4

local GetItemInfo        = (C_Item and C_Item.GetItemInfo) or GetItemInfo
local GetItemInfoInstant = (C_Item and C_Item.GetItemInfoInstant) or GetItemInfoInstant
local GetCVarBool        = (C_CVar and C_CVar.GetCVarBool) or GetCVarBool
local SetCVar            = (C_CVar and C_CVar.SetCVar) or SetCVar

local db
-- State of one loot window; reset on LOOT_CLOSED.
local handled  = false  -- already handled (LOOT_READY and LOOT_OPENED both trigger handling)
local managing = false  -- the window is ours to manage (not Shift/Ctrl/disabled)
local opened   = false  -- LOOT_OPENED arrived: the window may be closed
local pending, npending = {}, 0
local roomCache = {}    -- itemID -> free room in partial stacks (per window)

local Refresh           -- redraws the settings window (defined below)

local function Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cff33ccffLootFilter:|r " .. msg)
end

local function Money(copper)
    if GetCoinTextureString then return GetCoinTextureString(copper) end
    return tostring(copper) .. "c"
end

local function QualityRGB(q)
    local c = ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[q]
    if c and c.r then return c.r, c.g, c.b end
    return 1, 1, 1
end

local function QualityText(q)
    local name = QUALITY_LOWER[q] or tostring(q)
    local c = ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[q]
    if c and c.hex then return c.hex .. name .. "|r" end
    return name
end

-------------------------------------------------------------------------------
--  Free room for an item in partial stacks across all bags.
-------------------------------------------------------------------------------
local function StackRoom(itemID)
    local cached = roomCache[itemID]
    if cached then return cached end
    local room = 0
    local maxStack = select(8, GetItemInfo(itemID))
    if maxStack and maxStack > 1 then
        for bag = 0, LAST_BAG do
            for slot = 1, (C_Container.GetContainerNumSlots(bag) or 0) do
                local info = C_Container.GetContainerItemInfo(bag, slot)
                if info and info.itemID == itemID and (info.stackCount or 0) < maxStack then
                    room = room + (maxStack - info.stackCount)
                end
            end
        end
    end
    roomCache[itemID] = room
    return room
end

-------------------------------------------------------------------------------
--  Decision for one slot.
--  true: take; false: leave (plus a label for the report); nil: leave
--  silently (locked slot: a roll, another player's quest item).
-------------------------------------------------------------------------------
local function Decide(slot)
    local slotType = GetLootSlotType(slot)
    if slotType == SLOT_MONEY or slotType == SLOT_CURRENCY then return true end
    if slotType ~= SLOT_ITEM then return nil end

    local _, name, quantity, _, quality, locked, isQuestItem, questID = GetLootSlotInfo(slot)
    if locked then return nil end
    quantity = quantity or 1

    local link = GetLootSlotLink(slot)
    local itemID, classID
    if link then
        local id, _, _, _, _, cls = GetItemInfoInstant(link)
        itemID, classID = id, cls
    end
    local label = link or name

    if itemID then
        if db.never[itemID] then return false, label, quantity end
        if db.always[itemID] then return true end
    end
    if isQuestItem or questID or (classID and ALWAYS_CLASS[classID]) then return true end
    if quality and quality >= db.minQuality then return true end
    if db.mats and classID and MATS_CLASS[classID] then return true end

    if db.useValue then
        local price = link and select(11, GetItemInfo(link))
        if not price then return true end  -- no item data yet: safer to take it
        if price >= db.unitPrice then return true end
    end

    if db.stack and itemID then
        local room = StackRoom(itemID)
        if room >= quantity then
            roomCache[itemID] = room - quantity  -- a second slot of the same item on the corpse sees the remainder
            return true
        end
    end
    return false, label, quantity
end

local function TryClose()
    if managing and opened and db.close and npending <= 0 then
        CloseLoot()
    end
end

local function HandleLoot(autoLoot)
    if handled then return end
    handled = true
    if not db.enabled or autoLoot or IsShiftKeyDown() or IsControlKeyDown() then return end
    managing = true

    wipe(pending)
    wipe(roomCache)
    npending = 0
    local skipped = {}
    local n = GetNumLootItems()
    for slot = 1, n do
        local want, label, qty = Decide(slot)
        if want then
            pending[slot] = true
            npending = npending + 1
        elseif want == false and label then
            skipped[#skipped + 1] = (qty and qty > 1) and (label .. "×" .. qty) or label
        end
    end
    for slot = n, 1, -1 do
        if pending[slot] then LootSlot(slot) end
    end
    if db.report and #skipped > 0 then
        Print(L["left on the corpse: %s"]:format(table.concat(skipped, ", ")))
    end
    TryClose()
end

-------------------------------------------------------------------------------
--  The game's Auto Loot must be off, or the client takes everything itself.
-------------------------------------------------------------------------------
local function SyncAutoLootCVar(announce)
    if db.enabled then
        if GetCVarBool("autoLootDefault") then
            SetCVar("autoLootDefault", "0")
            db.turnedOffAutoLoot = true
            if announce then
                Print(L["turned off the game's Auto Loot: I filter your loot now. Shift while looting: take everything; Ctrl: open the window as is. Settings: /lootfilter"])
            end
        end
    elseif db.turnedOffAutoLoot then
        SetCVar("autoLootDefault", "1")
        db.turnedOffAutoLoot = nil
    end
end

local IsAddOnLoaded = (C_AddOns and C_AddOns.IsAddOnLoaded) or IsAddOnLoaded

local function WarnConflicts()
    -- The addon's old name: two copies of the filter would loot at the same time.
    if IsAddOnLoaded and IsAddOnLoaded("LootSieve") then
        Print("|cffff6060" .. L["the old LootSieve is installed too: delete the Interface/AddOns/LootSieve folder."] .. "|r")
    end
    if EllesmereUIDB and EllesmereUIDB.quickLoot then
        Print("|cffff6060" .. L["EllesmereUI Quick Loot is on: it takes everything. Turn it off in the EllesmereUI options (/eui)."] .. "|r")
    end
end

-------------------------------------------------------------------------------
--  Settings window
-------------------------------------------------------------------------------
local ACCENT   = { 0.05, 0.82, 0.62 }
local BG       = { 0.06, 0.06, 0.07, 0.97 }
local FIELD_BG = { 0.11, 0.11, 0.12, 1 }
local EDGE     = { 0.26, 0.26, 0.28, 1 }
local WHITE8   = "Interface\\Buttons\\WHITE8X8"
local PAD, WIN_W = 20, 460

local win
local refreshers = {}

local function Skin(f, bg, edge)
    f:SetBackdrop({ bgFile = WHITE8, edgeFile = WHITE8, edgeSize = 1 })
    f:SetBackdropColor(bg[1], bg[2], bg[3], bg[4] or 1)
    f:SetBackdropBorderColor(edge[1], edge[2], edge[3], edge[4] or 1)
end

local function Text(parent, template, str, r, g, b)
    local fs = parent:CreateFontString(nil, "OVERLAY", template)
    fs:SetJustifyH("LEFT")
    if str then fs:SetText(str) end
    if r then fs:SetTextColor(r, g, b) end
    return fs
end

local function Tooltip(owner, title, body)
    owner:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(title, 1, 1, 1)
        if body then GameTooltip:AddLine(body, nil, nil, nil, true) end
        GameTooltip:Show()
    end)
    owner:SetScript("OnLeave", function() GameTooltip:Hide() end)
end

local function Header(parent, str, y)
    local fs = Text(parent, "GameFontNormal", str, ACCENT[1], ACCENT[2], ACCENT[3])
    fs:SetPoint("TOPLEFT", PAD, y)
    local line = parent:CreateTexture(nil, "ARTWORK")
    line:SetTexture(WHITE8)
    line:SetVertexColor(EDGE[1], EDGE[2], EDGE[3], 0.8)
    line:SetHeight(1)
    line:SetPoint("LEFT", fs, "RIGHT", 8, 0)
    line:SetPoint("RIGHT", parent, "RIGHT", -PAD, 0)
    return fs
end

local function Checkbox(parent, label, key, y, desc, onChange)
    local b = CreateFrame("Button", nil, parent)
    b:SetSize(WIN_W - 2 * PAD, 22)
    b:SetPoint("TOPLEFT", PAD, y)
    local box = CreateFrame("Frame", nil, b, "BackdropTemplate")
    box:SetSize(16, 16)
    box:SetPoint("LEFT")
    Skin(box, FIELD_BG, EDGE)
    local tick = box:CreateTexture(nil, "OVERLAY")
    tick:SetTexture(WHITE8)
    tick:SetVertexColor(ACCENT[1], ACCENT[2], ACCENT[3])
    tick:SetPoint("TOPLEFT", 3, -3)
    tick:SetPoint("BOTTOMRIGHT", -3, 3)
    local fs = Text(b, "GameFontHighlight", label)
    fs:SetPoint("LEFT", box, "RIGHT", 8, 0)
    b:SetScript("OnClick", function()
        db[key] = not db[key]
        if onChange then onChange() end
        Refresh()
    end)
    if desc then Tooltip(b, label, desc) end
    refreshers[#refreshers + 1] = function() tick:SetShown(db[key] and true or false) end
    return b
end

local function Note(parent, str, y)
    local fs = Text(parent, "GameFontHighlightSmall", str, 0.62, 0.62, 0.66)
    fs:SetPoint("TOPLEFT", PAD, y)
    fs:SetWidth(WIN_W - 2 * PAD)
    fs:SetWordWrap(true)
    return fs
end

local function BuildQualityRow(parent, y)
    local gap = 6
    local w = math.floor((WIN_W - 2 * PAD - gap * MAX_QUALITY) / (MAX_QUALITY + 1))
    for q = 0, MAX_QUALITY do
        local b = CreateFrame("Button", nil, parent, "BackdropTemplate")
        b:SetSize(w, 26)
        b:SetPoint("TOPLEFT", PAD + q * (w + gap), y)
        Skin(b, FIELD_BG, EDGE)
        local r, g, bl = QualityRGB(q)
        local fs = Text(b, "GameFontHighlightSmall", QUALITY_NAMES[q], r, g, bl)
        fs:SetJustifyH("CENTER")
        fs:SetPoint("CENTER")
        b:SetScript("OnClick", function()
            db.minQuality = q
            Refresh()
        end)
        refreshers[#refreshers + 1] = function()
            local on = q >= db.minQuality
            if q == db.minQuality then
                b:SetBackdropColor(0.16, 0.16, 0.18, 1)
                b:SetBackdropBorderColor(r, g, bl, 1)
            elseif on then
                b:SetBackdropColor(0.13, 0.13, 0.15, 1)
                b:SetBackdropBorderColor(r * 0.5, g * 0.5, bl * 0.5, 1)
            else
                b:SetBackdropColor(FIELD_BG[1], FIELD_BG[2], FIELD_BG[3], 1)
                b:SetBackdropBorderColor(EDGE[1], EDGE[2], EDGE[3], 1)
            end
            fs:SetAlpha(on and 1 or 0.4)
        end
    end
end

local priceBoxes = {}

local function CommitPrice()
    local g = tonumber(priceBoxes[1]:GetText()) or 0
    local s = math.min(tonumber(priceBoxes[2]:GetText()) or 0, 99)
    local c = math.min(tonumber(priceBoxes[3]:GetText()) or 0, 99)
    db.unitPrice = g * 10000 + s * 100 + c
    Refresh()
end

local function BuildPriceRow(parent, y)
    local row = CreateFrame("Frame", nil, parent)
    row:SetSize(WIN_W - 2 * PAD, 24)
    row:SetPoint("TOPLEFT", PAD, y)
    local icons = { "Interface\\MoneyFrame\\UI-GoldIcon", "Interface\\MoneyFrame\\UI-SilverIcon",
                    "Interface\\MoneyFrame\\UI-CopperIcon" }
    local widths, letters = { 64, 40, 40 }, { 5, 2, 2 }
    local x = 0
    for i = 1, 3 do
        local e = CreateFrame("EditBox", nil, row, "BackdropTemplate")
        e:SetSize(widths[i], 22)
        e:SetPoint("LEFT", x, 0)
        e:SetAutoFocus(false)
        e:SetNumeric(true)
        e:SetMaxLetters(letters[i])
        e:SetFontObject(GameFontHighlight)
        e:SetJustifyH("RIGHT")
        e:SetTextInsets(4, 6, 0, 0)
        Skin(e, FIELD_BG, EDGE)
        e:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
        e:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
        e:SetScript("OnEditFocusGained", function(self)
            self:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 1)
            self:HighlightText()
        end)
        e:SetScript("OnEditFocusLost", function(self)
            self:SetBackdropBorderColor(EDGE[1], EDGE[2], EDGE[3], 1)
            self:HighlightText(0, 0)
            CommitPrice()
        end)
        e:SetScript("OnTabPressed", function()
            priceBoxes[i % 3 + 1]:SetFocus()
        end)
        priceBoxes[i] = e
        local icon = row:CreateTexture(nil, "ARTWORK")
        icon:SetTexture(icons[i])
        icon:SetSize(13, 13)
        icon:SetPoint("LEFT", e, "RIGHT", 4, 0)
        x = x + widths[i] + 24
    end
    local tail = Text(row, "GameFontHighlight", L["per unit"])
    tail:SetPoint("LEFT", x, 0)
    refreshers[#refreshers + 1] = function()
        local p = db.unitPrice or 0
        local vals = { math.floor(p / 10000), math.floor(p / 100) % 100, p % 100 }
        for i = 1, 3 do
            if not priceBoxes[i]:HasFocus() then priceBoxes[i]:SetText(tostring(vals[i])) end
        end
        row:SetAlpha(db.useValue and 1 or 0.4)
    end
end

local function BuildWindow()
    win = CreateFrame("Frame", "LootFilterForeverOptions", UIParent, "BackdropTemplate")
    win:SetSize(WIN_W, 520)
    win:SetPoint("CENTER")
    win:SetFrameStrata("DIALOG")
    win:SetToplevel(true)
    win:SetClampedToScreen(true)
    win:SetMovable(true)
    win:EnableMouse(true)
    win:RegisterForDrag("LeftButton")
    win:SetScript("OnDragStart", win.StartMoving)
    win:SetScript("OnDragStop", win.StopMovingOrSizing)
    Skin(win, BG, { 0, 0, 0, 1 })
    tinsert(UISpecialFrames, "LootFilterForeverOptions")  -- Esc closes it

    local logo = win:CreateTexture(nil, "ARTWORK")
    logo:SetTexture("Interface\\AddOns\\LootFilterForever\\icon")
    logo:SetSize(20, 20)
    logo:SetPoint("TOPLEFT", PAD, -14)
    local title = Text(win, "GameFontNormalLarge", "LootFilter", ACCENT[1], ACCENT[2], ACCENT[3])
    title:SetPoint("LEFT", logo, "RIGHT", 6, 0)
    local sub = Text(win, "GameFontHighlightSmall", "Forever", 0.62, 0.62, 0.66)
    sub:SetPoint("LEFT", title, "RIGHT", 8, -1)
    local close = CreateFrame("Button", nil, win, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -4, -4)

    local y = -50
    Checkbox(win, L["Filter enabled"], "enabled", y,
        L["When off, the game's normal Auto Loot works."], function() SyncAutoLootCVar(false) end)

    y = y - 38
    Header(win, L["Quality"], y)
    y = y - 22
    Note(win, L["Always take items of this quality and above."], y)
    y = y - 20
    BuildQualityRow(win, y)

    y = y - 44
    Header(win, L["Vendor price"], y)
    y = y - 24
    Checkbox(win, L["Take low-quality items with a high vendor price"], "useValue", y,
        L["For example, a grey goblet that sells for 80 silver. The threshold is per unit, not per stack."])
    y = y - 28
    BuildPriceRow(win, y)
    y = y - 28
    Note(win, L["0 in every field: take everything that sells."], y)

    y = y - 32
    Header(win, L["Also take"], y)
    y = y - 24
    Checkbox(win, L["Profession materials"], "mats", y,
        L["Ore, herbs, cloth, leather, meat, gems, recipes."])
    y = y - 26
    Checkbox(win, L["Fill partial stacks in the bags"], "stack", y,
        L["If the item is already in your bags and its stack has room, it needs no new slot, so it is taken."])

    y = y - 38
    Header(win, L["Loot window"], y)
    y = y - 24
    Checkbox(win, L["Close the window when the wanted loot is taken"], "close", y,
        L["The rest can be taken later: Shift while looting takes everything."])
    y = y - 26
    Checkbox(win, L["Report in chat what was left on the corpse"], "report", y)

    y = y - 38
    Header(win, L["Lists"], y)
    y = y - 24
    local lists = Note(win, "", y)
    lists:SetWidth(WIN_W - 2 * PAD - 120)
    local clear = CreateFrame("Button", nil, win, "UIPanelButtonTemplate")
    clear:SetSize(110, 22)
    clear:SetPoint("TOPRIGHT", -PAD, y + 4)
    clear:SetText(L["Clear"])
    clear:SetScript("OnClick", function()
        wipe(db.always)
        wipe(db.never)
        Refresh()
    end)
    refreshers[#refreshers + 1] = function()
        local a, n = 0, 0
        for _ in pairs(db.always) do a = a + 1 end
        for _ in pairs(db.never) do n = n + 1 end
        lists:SetText(string.format(L["Always take: %d, never take: %d.\n/lootfilter add [item], /lootfilter ignore [item]"], a, n))
        clear:SetEnabled(a + n > 0)
    end

    local foot = Text(win, "GameFontHighlightSmall",
        L["Shift while looting: take everything.   Ctrl: open the loot window as is."], 0.62, 0.62, 0.66)
    foot:SetPoint("BOTTOMLEFT", PAD, 14)

    win:SetHeight(-y + 70)
    win:SetScript("OnShow", function() Refresh() end)
end

Refresh = function()
    if not (win and db) then return end
    for i = 1, #refreshers do refreshers[i]() end
end

local function OpenWindow()
    if not win then BuildWindow() end
    win:Show()
    Refresh()
end

local function RegisterBlizzardPage()
    if not (Settings and Settings.RegisterCanvasLayoutCategory) then return end
    local panel = CreateFrame("Frame")
    panel.name = "LootFilter Forever"
    local btn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btn:SetSize(240, 30)
    btn:SetPoint("TOPLEFT", 16, -16)
    btn:SetText(L["Open LootFilter settings"])
    btn:SetScript("OnClick", function()
        if SettingsPanel and SettingsPanel:IsShown() then HideUIPanel(SettingsPanel) end
        C_Timer.After(0, OpenWindow)
    end)
    local category = Settings.RegisterCanvasLayoutCategory(panel, "LootFilter Forever")
    Settings.RegisterAddOnCategory(category)
end

-------------------------------------------------------------------------------
--  Commands
-------------------------------------------------------------------------------
local function ItemFromArg(arg)
    local id = arg:match("item:(%d+)") or arg:match("^%s*(%d+)%s*$")
    id = id and tonumber(id)
    if not id then return nil end
    local link = arg:match("|c.-|h|r") or arg:match("|H.-|h.-|h") or select(2, GetItemInfo(id)) or ("item " .. id)
    return id, link
end

local function Status()
    local parts = { L["money"], L["quest items"], L["%s and above"]:format(QualityText(db.minQuality)) }
    if db.mats then parts[#parts + 1] = L["profession materials"] end
    if db.useValue then parts[#parts + 1] = L["anything worth %s or more per unit"]:format(Money(db.unitPrice)) end
    if db.stack then parts[#parts + 1] = L["items that fit into partial stacks"] end
    local state = db.enabled and ("|cff40ff40" .. L["enabled"] .. "|r") or ("|cffff6060" .. L["disabled"] .. "|r")
    Print(L["%s. Takes: %s."]:format(state, table.concat(parts, ", ")))
end

local function Help()
    Status()
    Print(L["/lootfilter: settings window; /lootfilter on | off: enable or disable"])
    Print(L["/lootfilter quality 0-4: minimum quality (0 poor, 1 common, 2 uncommon, 3 rare, 4 epic)"])
    Print(L["/lootfilter value N: per-unit price threshold in silver (0.05 = 5 copper)"])
    Print(L["/lootfilter add [item]: always take; /lootfilter ignore [item]: never take"])
    Print(L["/lootfilter forget [item]: remove from the lists; /lootfilter list: show the lists"])
end

SLASH_LOOTFILTERFOREVER1 = "/lootfilter"
SLASH_LOOTFILTERFOREVER2 = "/lf"
SlashCmdList.LOOTFILTERFOREVER = function(msg)
    if not db then return end
    local cmd, arg = (msg or ""):match("^%s*(%S*)%s*(.-)%s*$")
    cmd = (cmd or ""):lower()

    if cmd == "" or cmd == "config" or cmd == "options" then
        OpenWindow()
    elseif cmd == "help" then
        Help()
    elseif cmd == "on" or cmd == "off" then
        db.enabled = (cmd == "on")
        SyncAutoLootCVar(false)
        Status()
    elseif cmd == "quality" then
        local q = tonumber(arg)
        if q and q >= 0 and q <= MAX_QUALITY then
            db.minQuality = math.floor(q)
            Print(L["take by quality: %s and above"]:format(QualityText(db.minQuality)))
        else
            Print(L["need a number from 0 to 4, for example: /lootfilter quality 2"])
        end
    elseif cmd == "value" then
        local s = tonumber((arg:gsub(",", ".")))
        if s and s >= 0 then
            db.unitPrice = math.floor(s * 100 + 0.5)
            Print(L["take everything worth %s or more per unit"]:format(Money(db.unitPrice)))
        else
            Print(L["need a number in silver, for example: /lootfilter value 10"])
        end
    elseif cmd == "add" or cmd == "ignore" or cmd == "forget" then
        local id, link = ItemFromArg(arg)
        if not id then
            Print(L["paste an item link (Shift-click) or its ID"])
            return
        end
        db.always[id], db.never[id] = nil, nil
        if cmd == "add" then
            db.always[id] = link
            Print(L["always take: %s"]:format(link))
        elseif cmd == "ignore" then
            db.never[id] = link
            Print(L["never take: %s"]:format(link))
        else
            Print(L["removed from the lists: %s"]:format(link))
        end
    elseif cmd == "list" then
        local a, b = {}, {}
        for _, l in pairs(db.always) do a[#a + 1] = l end
        for _, l in pairs(db.never) do b[#b + 1] = l end
        Print(L["always take: %s"]:format(#a > 0 and table.concat(a, ", ") or L["empty"]))
        Print(L["never take: %s"]:format(#b > 0 and table.concat(b, ", ") or L["empty"]))
    else
        Help()
        return
    end
    Refresh()
end

-------------------------------------------------------------------------------
--  Events
-------------------------------------------------------------------------------
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("LOOT_READY")
frame:RegisterEvent("LOOT_OPENED")
frame:RegisterEvent("LOOT_SLOT_CLEARED")
frame:RegisterEvent("LOOT_CLOSED")
frame:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1 ~= "LootFilterForever" then return end
        LootFilterForeverDB = LootFilterForeverDB or {}
        db = LootFilterForeverDB
        db.minValue = nil  -- 1.0 counted the threshold per stack; it is per unit now (unitPrice)
        for k, v in pairs(DEFAULTS) do
            if db[k] == nil then db[k] = v end
        end
        db.always = db.always or {}
        db.never = db.never or {}
        RegisterBlizzardPage()
        return
    end
    if not db then return end

    if event == "PLAYER_LOGIN" then
        SyncAutoLootCVar(true)
        WarnConflicts()
    elseif event == "LOOT_READY" then
        HandleLoot(arg1)
    elseif event == "LOOT_OPENED" then
        HandleLoot(arg1)
        opened = true
        TryClose()
    elseif event == "LOOT_SLOT_CLEARED" then
        if managing and pending[arg1] then
            pending[arg1] = nil
            npending = npending - 1
            TryClose()
        end
    elseif event == "LOOT_CLOSED" then
        handled, managing, opened = false, false, false
        wipe(pending)
        npending = 0
    end
end)
