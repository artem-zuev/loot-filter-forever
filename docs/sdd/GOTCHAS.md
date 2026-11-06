# Gotchas

### G-01 Game Auto Loot silently disables the filter
- Symptom: everything is looted; no report, no closing.
- Cause: with `autoLootDefault` on, the client loots every slot itself and `LOOT_READY` arrives with
  `autoLoot == true`, which the addon reads as "Shift held" and steps aside. A player who re-enables
  Auto Loot in the game options mid-session stays unfiltered until the next login or toggle.
- Avoid: Do not treat `autoLoot == true` as a bug to work around, because it is also how Shift-loot
  reaches the addon.
- retire_when: the CVar is re-synced on `CVAR_UPDATE`.
- Source: interview 2026-11-06 · Status: confirmed (2026-11-06) · Code: `SyncAutoLootCVar()`, `HandleLoot()`

### G-02 Another loot-all addon defeats the filter
- Symptom: same as G-01 although Auto Loot is off.
- Cause: EllesmereUI Quick Loot (`EllesmereUIDB.quickLoot`) or a still-installed LootSieve loots on
  `LOOT_READY` alongside this addon.
- Avoid: Do not drop the login warnings in `WarnConflicts()`, because they are the only hint the
  player gets.
- Source: inferred from `WarnConflicts()` · Status: inferred · Code: `WarnConflicts()`

### G-03 `string.lower` mangles Cyrillic
- Symptom: quality names in chat come out half lowercased.
- Cause: Lua 5.1 string functions work on bytes; Cyrillic letters are multibyte UTF-8.
- Avoid: Do not call `lower()`/`upper()` on Russian text, because it is left unchanged or broken;
  keep pre-cased tables like `QUALITY_LOWER`.
- Source: inferred from `CHANGELOG.md` 1.1.0 · Status: inferred · Code: `QualityText()`

### G-04 Unverified frame templates
- Symptom: a Lua error at window build time in game, or `unverified template` in the tests.
- Cause: the Forever client is retail-based but not every retail template is known to exist there.
  Only `BackdropTemplate`, `UIPanelButtonTemplate` and `UIPanelCloseButton` are confirmed (EllesmereUI
  uses them on this client); the stub `CreateFrame` errors on anything else.
- Avoid: Do not add another template to the code or to the stub allow-list, because it is
  unconfirmed until seen working in game.
- Source: interview 2026-11-06 · Status: confirmed (2026-11-06) · Code: `BuildWindow()`

### G-05 Two events open one window
- Symptom: slots looted twice, or `CloseLoot()` with no visible effect.
- Cause: both `LOOT_READY` and `LOOT_OPENED` fire for one window, and the loot frame exists only
  after `LOOT_OPENED`.
- Avoid: Do not call `CloseLoot()` or re-run the filter outside the `handled`/`opened` guards,
  because the order of the two events is not fixed.
- Source: inferred from the event handler · Status: inferred · Code: `HandleLoot()`, `TryClose()`

### G-06 The window stays open on purpose
- Symptom: after looting, the loot window is still open.
- Cause: a wanted slot never cleared: bind-on-pickup confirmation, full bags or a roll.
- Avoid: Do not close on a timer, because the player would lose the item they wanted.
- Source: inferred from `TryClose()` · Status: inferred · Code: `TryClose()`

### G-07 A unit price of 0 takes every item
- Symptom: with all price fields at 0, unsellable items are taken too, although the window note
  says "take everything that sells".
- Cause: the check is `price >= db.unitPrice` and an unsellable item has price 0. This is intended
  (R-17); the note is just loosely worded.
- Avoid: Do not change the check to `>` or skip price-0 items, because 0 meaning "take everything"
  is the intended behaviour.
- Source: interview 2026-11-06 · Status: confirmed (2026-11-06) · Code: `Decide()`

### G-08 Tests share state and index controls by creation order
- Symptom: unrelated checks fail after adding a window control or a test section.
- Cause: `tests/cases.lua` loads the addon once and runs sections in order; the window test finds
  controls by their position among created buttons and expects exactly 13 of them.
- Avoid: Do not insert a control or a section without updating the index map and the expected
  counts, because every later check shifts.
- Source: inferred from `tests/cases.lua` · Status: inferred

### G-09 The simulation is not the client
- Symptom: tests pass, the addon breaks in game.
- Cause: the stubs cannot model layout, fonts or client API differences.
- Avoid: Do not ship a change to looting or the window without an in-game check (kill and loot, a
  gathering node, Shift and Ctrl, click through `/lootfilter`), because the simulation cannot catch it.
- Source: inferred from `CLAUDE.md` · Status: inferred

### G-10 Lua 5.1 only
- Symptom: syntax error on load in game while a modern Lua accepted the file.
- Cause: the client runs Lua 5.1 (LuaJIT 2.1 compatible): no `goto`, no `//`, no `utf8` library.
- Avoid: Do not use Lua 5.2+ features, because the file then fails to load at all.
- Source: inferred from `CLAUDE.md` · Status: inferred

### G-11 Wanted slots are looted from the highest index down
- Symptom: none known; the order looks arbitrary.
- Cause: `HandleLoot()` calls `LootSlot` for pending slots from `n` down to 1. The reason is not
  recorded; a common one is that the client may shift slot indices as earlier slots clear.
- Avoid: Do not switch to ascending order without an in-game check on a corpse with several wanted
  slots, because the effect cannot be seen in the simulation.
- Source: inferred from `HandleLoot()` · Status: inferred · Code: `HandleLoot()`
