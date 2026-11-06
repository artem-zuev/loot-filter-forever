# LootFilter Forever architecture

LootFilter Forever is a single Lua file, `LootFilterForever/LootFilterForever.lua`, with no libraries. It is laid out top to
bottom as:

1. the Russian translations (`RU`) and the locale lookup `L`
2. defaults and lookup tables
3. state for the open loot window
4. the loot decision (`Decide`, `StackRoom`)
5. the loot window handling (`HandleLoot`, `TryClose`)
6. the Auto Loot setting (`SyncAutoLootCVar`) and conflict warning
7. the settings window
8. slash commands
9. the event frame

## Localization

Every user-facing string is written in English as a key into `L`: `L["Filter enabled"]`. `L` is the
`RU` table when `GetLocale() == "ruRU"`, otherwise an empty table; a metatable returns the key
itself for any missing entry, so English needs no table of its own. Strings with values use
`L["take by quality: %s and above"]:format(...)`, so word order can differ per language.

Quality names have two key sets: `Poor`…`Epic` for the window buttons and `poor`…`epic` for chat,
because `string.lower` cannot lowercase Cyrillic.

The TOC carries an English `## Notes` and a Russian `## Notes-ruRU`. The addon list icon is
`## IconTexture: Interface\AddOns\LootFilterForever\icon`, which points at `icon.tga` (64×64,
32-bit uncompressed TGA); the settings window shows the same texture next to its title.

## Event flow

| Event | Handler |
| --- | --- |
| `ADDON_LOADED` (`arg1 == "LootFilterForever"`) | Create or migrate `LootFilterForeverDB` and fill missing defaults. Register the Blizzard Settings page. |
| `PLAYER_LOGIN` | `SyncAutoLootCVar(true)`, then `WarnConflicts()`. The warning covers EllesmereUI Quick Loot, and the old LootSieve addon still being loaded. |
| `LOOT_READY` | `HandleLoot(autoLoot)`. |
| `LOOT_OPENED` | `HandleLoot(autoLoot)` (no-op if already handled), set `opened`, `TryClose()`. |
| `LOOT_SLOT_CLEARED` | If the slot was one we asked for, decrement `npending`, then `TryClose()`. |
| `LOOT_CLOSED` | Reset per-window state: `handled`, `managing`, `opened`, `pending`, `npending`. |

Both `LOOT_READY` and `LOOT_OPENED` call `HandleLoot`, guarded by `handled`, so the filter runs
exactly once per window whichever event arrives first.

## Handling one loot window

`HandleLoot(autoLoot)`:

1. Returns without touching anything (and without setting `managing`) when any of these hold:
   - the addon is disabled;
   - the client is auto-looting (`autoLoot == true`, i.e. Shift held with Auto Loot off);
   - Shift is down;
   - Ctrl is down.
2. Clears `pending` and `roomCache`, then runs `Decide(slot)` on every slot.
   - `true`: the slot is added to `pending` and counted in `npending`.
   - `false`: the item's link is added to the skipped list.
   - `nil`: the slot is ignored silently.
3. Calls `LootSlot` for each pending slot, **highest index first**, synchronously.
4. Prints the skipped list if `report` is on.
5. Calls `TryClose()`.

`TryClose()` calls `CloseLoot()` only when all of these hold:

- `managing`: this window is under our control;
- `opened`: `LOOT_OPENED` has fired, so the frame exists;
- `close` is on;
- `npending <= 0`.

So the window:

- stays open while any wanted slot has not cleared, e.g. a bind-on-pickup confirmation, a full
  inventory or a roll;
- closes right after `LOOT_OPENED` when nothing was wanted;
- closes as soon as the last wanted slot clears.

When everything on the corpse was taken, the client closes the window by itself.

## Decision order (`Decide`)

The first matching rule wins:

| # | Condition | Result |
| --- | --- | --- |
| 1 | Slot type is Money or Currency | take |
| 2 | Slot type is not Item | ignore (`nil`) |
| 3 | `locked` from `GetLootSlotInfo` (rolls, other players' quest items) | ignore (`nil`) |
| 4 | item ID in `db.never` | leave |
| 5 | item ID in `db.always` | take |
| 6 | `isQuestItem`, `questID`, or class Questitem (12), Container (1) or Key (13) | take |
| 7 | `quality >= db.minQuality` | take |
| 8 | `db.mats` and class Tradegoods (7), Recipe (9), Gem (3) or Reagent (5) | take |
| 9 | `db.useValue` and the vendor price is unknown (item not cached) | take (safe default) |
| 10 | `db.useValue` and vendor price per unit `>= db.unitPrice` | take |
| 11 | `db.stack` and `StackRoom(itemID) >= quantity` | take; the room is reduced by `quantity` |
| 12 | otherwise | leave |

Class IDs come from `Enum.ItemClass`, with the numeric fallbacks above.

Vendor price is field 11 of `C_Item.GetItemInfo`. Maximum stack size is field 8.

### Stack fill (`StackRoom`)

`StackRoom(itemID)` returns the free room in the partial stacks of that item already in the bags:

- It scans bags `0 .. NUM_TOTAL_EQUIPPED_BAG_SLOTS` (fallback `NUM_BAG_SLOTS`, then 4). The range
  includes the reagent bag where the client has one.
- It reads `C_Container.GetContainerItemInfo(bag, slot).itemID` and `.stackCount`.
- It sums `maxStack - stackCount` over every stack of that item below the maximum. Items with a
  maximum stack of 1 have no room.
- The result is cached per loot window in `roomCache` and reduced as slots are claimed. Two slots of
  the same item on one corpse cannot both claim the same room.

An item is taken only when its **whole** quantity fits. Partial overflow would need a new slot, so
it is left.

## Auto Loot setting

The game setting `autoLootDefault` must be off. Otherwise the client loots every slot before
`LOOT_READY` handlers can choose, and `LOOT_READY` reports `autoLoot == true`, so the addon steps
aside.

`SyncAutoLootCVar(announce)` runs at login and whenever the addon is switched on or off:

- **Enabled, and `autoLootDefault` is on:** sets it to `0` and records
  `db.turnedOffAutoLoot = true`. Prints a notice when `announce` is set.
- **Disabled, and `db.turnedOffAutoLoot` is set:** restores `autoLootDefault` to `1` and clears the
  flag. Disabling never turns on Auto Loot for a player who had it off before installing.

Turning Auto Loot back on in the game settings mid-session disables filtering until the next login
or toggle. Re-checking on `CVAR_UPDATE` is an open idea.

## Saved variables

`LootFilterForeverDB` is declared in the TOC with `## SavedVariables`, so it is account-wide.

| Key | Type | Default | Meaning |
| --- | --- | --- | --- |
| `enabled` | boolean | `true` | filter on/off |
| `minQuality` | number 0–4 | `2` | take items of this quality and above |
| `useValue` | boolean | `true` | price rule on/off |
| `unitPrice` | number (copper) | `1000` | per-unit vendor price threshold |
| `mats` | boolean | `true` | take profession materials |
| `stack` | boolean | `true` | take items that fit existing partial stacks |
| `close` | boolean | `true` | close the loot window when done |
| `report` | boolean | `true` | print skipped items in chat |
| `always` | table `itemID → link` | `{}` | always take |
| `never` | table `itemID → link` | `{}` | never take |
| `turnedOffAutoLoot` | boolean / nil | nil | we switched `autoLootDefault` off and owe a restore |

The list values are display strings: the item link if known, else `"item <id>"`. Only the keys
matter for filtering.

### Migration

Version 1.0 stored a per-stack threshold in `minValue`. On load it is set to `nil`, and `unitPrice`
takes its default.

To add a key, give it a default in `DEFAULTS`. The load loop fills only keys that are `nil`, so
existing choices survive.

## Settings window

The window is built lazily the first time it is opened.

- **Frame:** global name `LootFilterForeverOptions`. It is in `UISpecialFrames` (Esc closes it), movable,
  clamped, strata `DIALOG`.
- **Look:** flat dark panels with 1 px borders, drawn with `BackdropTemplate` and the
  `Interface\Buttons\WHITE8X8` texture. The accent colour is `ACCENT = {0.05, 0.82, 0.62}`, the teal
  that EllesmereUI uses.
- **Controls:** check boxes are custom `Button` + texture widgets, not `UICheckButtonTemplate`.
  Quality buttons are five backdrop buttons. Price inputs are three `EditBox` frames with
  `SetNumeric(true)`.
- **Price input:** the value is committed in `OnEditFocusLost` (Enter, Esc, Tab or a click elsewhere
  all end up there). Silver and copper are clamped to 99, and empty fields count as 0. Tab cycles
  through the three boxes.
- **Refresh:** every control registers a refresher closure in `refreshers`. `Refresh()` runs them
  all; it is a no-op until the window exists. Any setting change, from the window or a slash command,
  calls `Refresh()`.
- **Height:** computed from the running `y` offset after layout.
- **Blizzard Settings entry:** `RegisterBlizzardPage()` registers a canvas category with one button.
  The button hides `SettingsPanel` and opens our window on the next frame, the same pattern
  EllesmereUI uses on this client.

## Slash commands

`SLASH_LOOTFILTERFOREVER1 = "/lootfilter"`, `SLASH_LOOTFILTERFOREVER2 = "/lf"`. The handler splits the input into a
command and an argument.

- Item arguments accept a full link (`|c…|Hitem:ID…|h[Name]|h|r`), a bare `|H…|h…|h` link, or a
  numeric ID.
- `value` accepts a comma or a dot as the decimal separator.

After every successful command the window is refreshed.

## Tests

`tests/wow_stubs.lua` stubs the client:

- **Loot and items:** loot slots, item info and bag contents are plain tables that the cases fill
  (`SLOTS`, `ITEMS`, `BAGS`).
- **Side effects:** `LootSlot`, `CloseLoot`, `SetCVar` and chat output are appended to `LOG`.
- **Frames:** generic mocks that accept any method call. `CreateFrame` raises an error for any
  template other than `BackdropTemplate`, `UIPanelButtonTemplate` and `UIPanelCloseButton`, the ones
  verified on the WoW Forever client. `SetBackdrop` errors unless the frame used `BackdropTemplate`.

`GetLocale()` returns the `LOCALE` global, `"ruRU"` by default.

`tests/cases.lua` loads the addon once and runs 63 checks in order; only the last section loads it
again, as an English client. They cover:

- saved-variable migration
- the login Auto Loot notice and conflict warnings
- every decision rule
- window closing
- Shift and Ctrl
- stack fill
- the price toggle
- every control in the settings window
- the slash commands
- the locale table: read from the source file, every `L["..."]` key must have an `RU` entry, every
  `RU` entry must be used, and no Cyrillic may appear outside `RU`
- an English client (`LOCALE = "enUS"`): the login notice and the status line

The simulation cannot catch layout problems, font issues or real client API differences, so check
changes in game as well.
