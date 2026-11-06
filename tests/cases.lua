-- Simulation test cases for LootFilter Forever. Loaded by tests/run.lua after
-- tests/wow_stubs.lua and LootFilterForever/LootFilterForever.lua. The addon is loaded once
-- (the last section loads it again as an English client), so sections run in order and share
-- state on purpose.

local passed = 0
local function check(cond, msg)
    if not cond then error("FAIL: " .. msg, 2) end
    passed = passed + 1
    print("  ok  " .. msg)
end
local function section(title) wipe(LOG); print("== " .. title) end
local function has(s) for _, l in ipairs(LOG) do if l == s then return true end end return false end
local function count(prefix)
    local n = 0
    for _, l in ipairs(LOG) do if l:sub(1, #prefix) == prefix then n = n + 1 end end
    return n
end
local function chatLine(pattern)
    for _, l in ipairs(LOG) do if l:find(pattern) then return l end end
end
local function corpse(slots) SLOTS = slots end
local function loot() fire("LOOT_READY", false) end
local function closeLoot() fire("LOOT_CLOSED") end

ITEMS = {
    [100] = { class = 12, price = 0,    name = "Quest Drop",    stack = 1 },
    [101] = { class = 15, price = 5,    name = "Broken Fang",   stack = 5 },
    [102] = { class = 4,  price = 300,  name = "Green Bracers", stack = 1 },
    [103] = { class = 7,  price = 13,   name = "Linen Cloth",   stack = 20 },
    [104] = { class = 2,  price = 100,  name = "White Sword",   stack = 1 },
    [105] = { class = 15, price = 9000, name = "Ornate Goblet", stack = 1 },
    [106] = { class = 4,  price = 50,   name = "Locked Thing",  stack = 1 },
    [107] = { class = 15, name = "Uncached", uncached = true },
    [108] = { class = 0,  price = 600,  name = "Bread",         stack = 20 },
    [109] = { class = 15, price = 2,    name = "Grey Pebble",   stack = 10 },
}

-------------------------------------------------------------------------------
section("load: 1.0 saved variables are migrated")
LootFilterForeverDB = { minValue = 5000, mats = false, enabled = true, always = {}, never = {} }
fire("ADDON_LOADED", "SomeOtherAddon")
check(LootFilterForeverDB.unitPrice == nil, "ignores ADDON_LOADED for other addons")
fire("ADDON_LOADED", "LootFilterForever")
check(LootFilterForeverDB.minValue == nil and LootFilterForeverDB.unitPrice == 1000, "per-stack minValue dropped, unitPrice defaults to 10s")
check(LootFilterForeverDB.mats == false, "existing preference kept")
check(LootFilterForeverDB.stack == true and LootFilterForeverDB.useValue == true and LootFilterForeverDB.close == true, "new keys get defaults")
check(#SETTINGS_PAGES == 1 and SETTINGS_PAGES[1].name == "LootFilter Forever", "Blizzard Settings page registered")
LootFilterForeverDB.mats = true

section("login: game auto loot is turned off, conflicts are reported")
EllesmereUIDB = { quickLoot = true }
fire("PLAYER_LOGIN")
check(CVARS.autoLootDefault == "0" and LootFilterForeverDB.turnedOffAutoLoot == true, "autoLootDefault set to 0 and remembered")
check(chatLine("выключил автосбор") ~= nil, "login notice printed")
check(chatLine("Быстрый сбор") ~= nil, "EllesmereUI Quick Loot conflict reported")
check(chatLine("LootSieve") == nil, "no old-name warning while LootSieve is absent")
EllesmereUIDB = nil
LOADED_ADDONS.LootSieve = true
wipe(LOG); fire("PLAYER_LOGIN")
check(chatLine("старый LootSieve") ~= nil, "warns when the old LootSieve addon is still installed")
LOADED_ADDONS.LootSieve = nil

-------------------------------------------------------------------------------
section("rules: one corpse with every kind of slot")
BAGS = {}
corpse({
    { type = 2 },                                                          -- 1 money
    { type = 1, id = 100, name = "Quest Drop", q = 1, quest = true },      -- 2 quest
    { type = 1, id = 101, name = "Broken Fang", q = 0, qty = 2 },          -- 3 cheap grey
    { type = 1, id = 102, name = "Green Bracers", q = 2 },                 -- 4 quality
    { type = 1, id = 103, name = "Linen Cloth", q = 1, qty = 2 },          -- 5 mats
    { type = 1, id = 104, name = "White Sword", q = 1 },                   -- 6 cheap white
    { type = 1, id = 105, name = "Ornate Goblet", q = 0 },                 -- 7 valuable grey
    { type = 1, id = 106, name = "Locked Thing", q = 3, locked = true },   -- 8 locked
    { type = 1, id = 107, name = "Uncached", q = 1 },                      -- 9 no item data
})
loot()
check(has("LOOT 1") and has("LOOT 2") and has("LOOT 4") and has("LOOT 5") and has("LOOT 7") and has("LOOT 9"),
      "takes money, quest, quality, mats, unit price, uncached")
check(not has("LOOT 3") and not has("LOOT 6") and not has("LOOT 8"), "leaves cheap grey, cheap white, locked")
check(count("LOOT") == 6, "exactly six LootSlot calls")
local report = chatLine("оставлено")
check(report and report:find("Broken Fang%]|h|r×2") and report:find("White Sword") and not report:find("Locked"),
      "report lists skipped items with counts and omits locked slots")
check(not has("CLOSE"), "no CloseLoot before LOOT_OPENED")

section("closing: waits for every wanted slot")
loot()
check(count("LOOT") == 0, "second LOOT_READY for the same window is ignored")
fire("LOOT_OPENED", false, false)
check(not has("CLOSE"), "stays open while wanted slots are pending")
for _, s in ipairs({ 9, 7, 5, 4, 2 }) do fire("LOOT_SLOT_CLEARED", s) end
fire("LOOT_SLOT_CLEARED", 3)
check(not has("CLOSE"), "a non-wanted slot clearing does not close")
fire("LOOT_SLOT_CLEARED", 1)
check(count("CLOSE") == 1, "closes after the last wanted slot clears")
closeLoot()

section("closing: nothing wanted")
corpse({ { type = 1, id = 101, name = "Broken Fang", q = 0 } })
loot()
check(count("LOOT") == 0 and not has("CLOSE"), "nothing looted and not closed during LOOT_READY")
fire("LOOT_OPENED", false)
check(count("CLOSE") == 1, "closed on LOOT_OPENED")
closeLoot()

section("modifiers: Shift and Ctrl")
SHIFT = true
fire("LOOT_READY", true); fire("LOOT_OPENED", true)
check(count("LOOT") + count("CLOSE") + count("CHAT") == 0, "Shift: addon stays out, client auto-loots")
closeLoot(); SHIFT = false
CTRL = true
loot(); fire("LOOT_OPENED", false)
check(count("LOOT") + count("CLOSE") == 0, "Ctrl: window shown untouched")
closeLoot(); CTRL = false

-------------------------------------------------------------------------------
section("stacks and per-unit price")
BAGS = { [0] = { [1] = { 101, 3 }, [2] = { 109, 10 } }, [1] = { [5] = { 101, 5 } } }
corpse({
    { type = 1, id = 101, name = "Broken Fang", q = 0, qty = 2 },  -- 1 fits the 3/5 stack
    { type = 1, id = 101, name = "Broken Fang", q = 0, qty = 1 },  -- 2 room already used
    { type = 1, id = 104, name = "White Sword", q = 1 },           -- 3 does not stack
    { type = 1, id = 105, name = "Ornate Goblet", q = 0 },         -- 4 90s each
    { type = 1, id = 108, name = "Bread", q = 1, qty = 5 },        -- 5 6s each (30s stack)
    { type = 1, id = 109, name = "Grey Pebble", q = 0 },           -- 6 only a full stack
    { type = 1, id = 103, name = "Linen Cloth", q = 1, qty = 3 },  -- 7 mats
})
loot()
check(has("LOOT 1") and has("LOOT 4") and has("LOOT 7") and count("LOOT") == 3, "takes stack fill, unit price, mats")
check(not has("LOOT 2") and not has("LOOT 5") and not has("LOOT 6"),
      "leaves overflow, cheap-per-unit stack, full-stack item")
closeLoot(); wipe(LOG)

LootFilterForeverDB.stack = false
loot()
check(not has("LOOT 1") and has("LOOT 4"), "stack option off: no stack fill")
closeLoot(); LootFilterForeverDB.stack = true; wipe(LOG)

LootFilterForeverDB.never[101] = "Broken Fang"
loot()
check(not has("LOOT 1"), "never-list beats stack fill")
closeLoot(); LootFilterForeverDB.never[101] = nil; wipe(LOG)

LootFilterForeverDB.always[104] = "White Sword"
loot()
check(has("LOOT 3"), "always-list takes an item that matches no rule")
closeLoot(); LootFilterForeverDB.always[104] = nil; wipe(LOG)

section("price rule switched off")
LootFilterForeverDB.useValue = false
corpse({ { type = 1, id = 105, name = "Ornate Goblet", q = 0 }, { type = 1, id = 107, name = "Uncached", q = 0 } })
loot()
check(count("LOOT") == 0, "valuable and uncached items are left")
closeLoot(); LootFilterForeverDB.useValue = true; wipe(LOG)
loot()
check(has("LOOT 1") and has("LOOT 2"), "back on: both taken")
closeLoot()

-------------------------------------------------------------------------------
section("options window")
SlashCmdList.LOOTFILTERFOREVER("")
local win = _G.LootFilterForeverOptions
check(win and win._shown, "/lootfilter opens the window")
local buttons, boxes = {}, {}
for _, f in ipairs(CREATED) do
    if f._kind == "Button" and f._scripts.OnClick then buttons[#buttons + 1] = f end
    if f._kind == "EditBox" then boxes[#boxes + 1] = f end
end
check(#buttons == 13 and #boxes == 3, "13 clickable controls and 3 price boxes")
-- buttons[1] is the Blizzard Settings page button, created at ADDON_LOADED.
local B = { page = buttons[1], enabled = buttons[2],
            q = { [0] = buttons[3], buttons[4], buttons[5], buttons[6], buttons[7] },
            useValue = buttons[8], mats = buttons[9], stack = buttons[10],
            close = buttons[11], report = buttons[12], clear = buttons[13] }
check(boxes[1]._text == "0" and boxes[2]._text == "10" and boxes[3]._text == "0", "price shows 0g 10s 0c")
B.q[1]:Click(); check(LootFilterForeverDB.minQuality == 1, "quality button: Common")
B.q[3]:Click(); check(LootFilterForeverDB.minQuality == 3, "quality button: Rare")
for _, key in ipairs({ "useValue", "mats", "stack", "close", "report" }) do
    B[key]:Click(); local off = LootFilterForeverDB[key] == false
    B[key]:Click(); check(off and LootFilterForeverDB[key] == true, "checkbox toggles " .. key)
end
boxes[1]:SetText("1"); boxes[2]:SetText("5"); boxes[3]:SetText("7"); boxes[1]:SetFocus(); boxes[1]:ClearFocus()
check(LootFilterForeverDB.unitPrice == 10507, "1g 5s 7c commits as 10507 copper")
boxes[2]:SetText("150"); boxes[2]:SetFocus(); boxes[2]:ClearFocus()
check(LootFilterForeverDB.unitPrice == 19907 and boxes[2]._text == "99", "silver is clamped to 99")
boxes[1]:SetText(""); boxes[2]:SetText(""); boxes[3]:SetText(""); boxes[3]:SetFocus(); boxes[3]:ClearFocus()
check(LootFilterForeverDB.unitPrice == 0 and boxes[1]._text == "0", "empty fields commit as 0")
B.enabled:Click()
check(LootFilterForeverDB.enabled == false and CVARS.autoLootDefault == "1", "disabling restores game auto loot")
B.enabled:Click()
check(LootFilterForeverDB.enabled == true and CVARS.autoLootDefault == "0", "enabling turns it off again")
SlashCmdList.LOOTFILTERFOREVER("add 104"); SlashCmdList.LOOTFILTERFOREVER("ignore 105")
check(next(LootFilterForeverDB.always) ~= nil and next(LootFilterForeverDB.never) ~= nil, "lists filled from slash commands")
B.clear:Click()
check(next(LootFilterForeverDB.always) == nil and next(LootFilterForeverDB.never) == nil, "Clear empties both lists")
win._shown = false
B.page:Click()
check(win._shown, "Blizzard Settings page button opens the window")

-------------------------------------------------------------------------------
section("slash commands")
SlashCmdList.LOOTFILTERFOREVER("value 0,05")
check(LootFilterForeverDB.unitPrice == 5 and boxes[3]._text == "5", "value accepts a comma and refreshes the window")
SlashCmdList.LOOTFILTERFOREVER("quality 2")
check(LootFilterForeverDB.minQuality == 2, "quality 2")
SlashCmdList.LOOTFILTERFOREVER("quality 9")
check(LootFilterForeverDB.minQuality == 2, "out-of-range quality rejected")
SlashCmdList.LOOTFILTERFOREVER("add |cffffffff|Hitem:101::|h[Broken Fang]|h|r")
check(LootFilterForeverDB.always[101] == "|cffffffff|Hitem:101::|h[Broken Fang]|h|r", "add stores the full coloured link")
SlashCmdList.LOOTFILTERFOREVER("ignore 101")
check(LootFilterForeverDB.never[101] ~= nil and LootFilterForeverDB.always[101] == nil, "ignore moves an item between lists")
SlashCmdList.LOOTFILTERFOREVER("forget 101")
check(LootFilterForeverDB.never[101] == nil, "forget removes it")
wipe(LOG)
SlashCmdList.LOOTFILTERFOREVER("help")
local status = chatLine("Берёт")
check(status and status:find("зелёные|r и выше", 1, true) and not status:find("Зелёные", 1, true),
      "status uses the lowercase Cyrillic quality name")
SlashCmdList.LOOTFILTERFOREVER("off")
check(CVARS.autoLootDefault == "1", "off restores game auto loot")
wipe(LOG); loot()
check(count("LOOT") == 0, "disabled: nothing looted")
closeLoot()
SlashCmdList.LOOTFILTERFOREVER("on")
check(CVARS.autoLootDefault == "0", "on turns game auto loot off again")

-------------------------------------------------------------------------------
section("locale: every string is translated")
local src = assert(io.open(ADDON_FILE)):read("*a")
local translated, used, missing, unused = {}, {}, {}, {}
for key in src:match("local RU = (%b{})"):gmatch('%[(".-")%]%s*=') do translated[key] = true end
for key in src:gmatch('L%[(".-")%]') do used[key] = true end
for key in pairs(used) do if not translated[key] then missing[#missing + 1] = key end end
for key in pairs(translated) do if not used[key] then unused[#unused + 1] = key end end
check(#missing == 0, "every L[...] key has a Russian translation " .. table.concat(missing, " "))
check(#unused == 0, "every Russian translation is used " .. table.concat(unused, " "))
check(not src:gsub("local RU = %b{}", ""):find("[\208\209]"), "no Cyrillic outside the RU table")

section("locale: English client")
LOCALE, EVENTFRAME, LootFilterForeverDB = "enUS", nil, nil
dofile(ADDON_FILE)
fire("ADDON_LOADED", "LootFilterForever")
CVARS.autoLootDefault = "1"
fire("PLAYER_LOGIN")
check(chatLine("turned off the game's Auto Loot") ~= nil, "login notice in English")
SlashCmdList.LOOTFILTERFOREVER("help")
status = chatLine("Takes:")
check(status and status:find("uncommon|r and above", 1, true), "status in English with the lowercase quality name")

print(string.format("\nALL %d CHECKS PASSED", passed))
