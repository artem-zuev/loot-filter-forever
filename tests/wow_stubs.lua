-- Minimal stand-ins for the WoW client API used by LootFilter Forever, enough to run
-- tests/cases.lua outside the game. Loot slots, items and bag contents are
-- plain tables (SLOTS, ITEMS, BAGS) that the cases fill in; every LootSlot,
-- CloseLoot, SetCVar and chat line is appended to LOG. UI frames are generic
-- mocks that accept any method; only templates verified on the WoW Forever
-- client are allowed (see CLAUDE.md).
Enum = { LootSlotType = { None = 0, Item = 1, Money = 2, Currency = 3 },
         ItemClass = { Consumable=0, Container=1, Weapon=2, Gem=3, Armor=4, Reagent=5, Tradegoods=7, Recipe=9, Questitem=12, Key=13, Miscellaneous=15 } }
LOG = {}
local function log(s) LOG[#LOG+1] = s end
LOCALE = "ruRU"
function GetLocale() return LOCALE end
DEFAULT_CHAT_FRAME = { AddMessage = function(_, m) log("CHAT " .. m) end }
ITEM_QUALITY_COLORS = { [0]={r=.6,g=.6,b=.6,hex="|cff9d9d9d"}, {r=1,g=1,b=1,hex="|cffffffff"}, {r=.1,g=1,b=0,hex="|cff1eff00"}, {r=0,g=.4,b=.9,hex="|cff0070dd"}, {r=.6,g=.2,b=.9,hex="|cffa335ee"} }
function GetCoinTextureString(c) return string.format("%dg%ds%dc", math.floor(c/10000), math.floor(c/100)%100, c%100) end
function wipe(t) for k in pairs(t) do t[k] = nil end return t end
tinsert = table.insert
CVARS = { autoLootDefault = "1" }
C_CVar = { GetCVarBool = function(k) return CVARS[k] == "1" end, SetCVar = function(k, v) CVARS[k] = v; log("CVAR " .. k .. "=" .. v) end }
C_Timer = { After = function(_, f) f() end }
LOADED_ADDONS = {}
C_AddOns = { IsAddOnLoaded = function(name) return LOADED_ADDONS[name] == true end }
NUM_TOTAL_EQUIPPED_BAG_SLOTS = 5
SHIFT, CTRL = false, false
function IsShiftKeyDown() return SHIFT end
function IsControlKeyDown() return CTRL end
SLOTS, ITEMS, BAGS = {}, {}, {}
function GetNumLootItems() return #SLOTS end
function GetLootSlotType(i) local s = SLOTS[i]; return s and s.type or 0 end
function GetLootSlotInfo(i) local s = SLOTS[i]; return "tex", s.name, s.qty or 1, nil, s.q, s.locked, s.quest, nil end
function GetLootSlotLink(i) local s = SLOTS[i]; if s.id then return "|cffffffff|Hitem:" .. s.id .. "::|h[" .. s.name .. "]|h|r" end end
C_Item = {
  GetItemInfoInstant = function(link) local id = type(link)=="number" and link or tonumber(tostring(link):match("item:(%d+)")); local it = ITEMS[id]; return id, nil, nil, nil, nil, it and it.class end,
  GetItemInfo = function(x) local id = type(x) == "number" and x or tonumber(tostring(x):match("item:(%d+)")); local it = ITEMS[id]; if not it or it.uncached then return nil end
     return it.name, "|cffffffff|Hitem:" .. id .. "::|h[" .. (it.name or "?") .. "]|h|r", 1,1,1,"","", it.stack or 1, "", 1, it.price end,
}
C_Container = {
  GetContainerNumSlots = function(bag) return BAGS[bag] and 20 or 0 end,
  GetContainerItemInfo = function(bag, slot) local b = BAGS[bag]; local s = b and b[slot]; if s then return { itemID = s[1], stackCount = s[2] } end end,
}
function LootSlot(i) log("LOOT " .. i) end
function CloseLoot() log("CLOSE") end
SlashCmdList = {}
-- generic UI mock
local Mock = {}
Mock.__index = function(t, k) local v = rawget(Mock, k); if v then return v end; return function() end end
local function newMock(kind, tmpl) return setmetatable({ _kind = kind, _tmpl = tmpl, _scripts = {}, _text = "", _shown = false, _focus = false, _bd = false }, Mock) end
function Mock:CreateFontString() return newMock("FontString") end
function Mock:CreateTexture() return newMock("Texture") end
function Mock:SetScript(n, f) self._scripts[n] = f end
function Mock:SetText(t) self._text = t end
function Mock:GetText() return self._text end
function Mock:SetShown(v) self._shown = v and true or false end
function Mock:Show() self._shown = true; if self._scripts.OnShow then self._scripts.OnShow(self) end end
function Mock:IsShown() return self._shown end
function Mock:HasFocus() return self._focus == true end
function Mock:SetFocus() self._focus = true end
function Mock:ClearFocus() self._focus = false; if self._scripts.OnEditFocusLost then self._scripts.OnEditFocusLost(self) end end
function Mock:RegisterEvent(e) local ev = rawget(self, "ev") or {}; rawset(self, "ev", ev); ev[e] = true end
function Mock:SetEnabled(v) self._enabled = v end
function Mock:SetBackdrop(b) assert(type(b) == "table", "SetBackdrop needs table"); self._bd = true end
function Mock:SetBackdropColor() assert(self._bd, "SetBackdropColor before SetBackdrop") end
function Mock:SetBackdropBorderColor() assert(self._bd, "SetBackdropBorderColor before SetBackdrop") end
function Mock:Click() assert(self._scripts.OnClick, "no OnClick"); self._scripts.OnClick(self) end
CREATED = {}
function CreateFrame(kind, name, parent, tmpl)
  if tmpl and tmpl ~= "BackdropTemplate" and tmpl ~= "UIPanelButtonTemplate" and tmpl ~= "UIPanelCloseButton" then error("unverified template " .. tmpl) end
  local f = newMock(kind, tmpl)
  if tmpl ~= "BackdropTemplate" then f.SetBackdrop = function() error("SetBackdrop without BackdropTemplate") end end
  CREATED[#CREATED+1] = f
  if name then _G[name] = f end
  if not EVENTFRAME and kind == "Frame" and not parent then EVENTFRAME = f end
  return f
end
UIParent = newMock("Frame"); GameTooltip = newMock("GameTooltip"); UISpecialFrames = {}
GameFontHighlight, GameFontNormal = {}, {}
SETTINGS_PAGES = {}
Settings = { RegisterCanvasLayoutCategory = function(panel, name) SETTINGS_PAGES[#SETTINGS_PAGES+1] = { panel = panel, name = name }; return { GetID = function() return 1 end } end,
             RegisterAddOnCategory = function() end }
function HideUIPanel() end
function fire(e, ...) if rawget(EVENTFRAME, "ev")[e] then EVENTFRAME._scripts.OnEvent(EVENTFRAME, e, ...) end end
