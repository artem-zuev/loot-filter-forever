# Business rules

The full first-match decision table is in [ARCHITECTURE.md](../ARCHITECTURE.md#decision-order-decide);
this file holds the rules behind it and what must not change.

## Glossary

- `slot` — one entry of a loot window (money, currency or an item stack), addressed by index.
- `wanted slot` — a slot `Decide` returned `true` for; kept in `pending` until `LOOT_SLOT_CLEARED`.
- `managed window` — a loot window the addon handles; not one opened with Shift, with Ctrl or while
  the addon is disabled.
- `unit price` — the vendor sell price of one item (field 11 of `GetItemInfo`), in copper; the
  threshold is `db.unitPrice`.
- `stack room` — free space in partial stacks of the same item already in the bags, reagent bag
  included.
- `always` / `never` lists — per-account sets of item IDs; the values are display strings only.
- `report` — the chat line listing what was left on the corpse.
- quality tiers — 0 Poor (grey), 1 Common (white), 2 Uncommon (green), 3 Rare (blue), 4 Epic
  (purple); the addon's range stops at 4.

## Rules

### Always taken

- R-01 Money and currency slots are always taken; the lists do not apply to them.
  Source: inferred from `Decide()` · Status: inferred · Code: `Decide()`
- R-02 Quest items (`isQuestItem` or a `questID`), containers and keys are taken regardless of
  quality, price and the toggles, but an item on the never list is still left.
  Source: inferred from `Decide()` · Status: inferred · Code: `Decide()`
- R-03 Slots the client reports as `locked` (rolls, other players' quest items) are neither taken
  nor reported.
  Source: interview 2026-11-06 · Status: confirmed (2026-11-06) · Code: `Decide()`

### Lists

- R-04 The never list beats every item rule, quest items and stack fill included. The always list
  beats every rule after it.
  Source: inferred from `Decide()` and `tests/cases.lua` · Status: inferred · Code: `Decide()`
- R-05 An item is in at most one list: `add`, `ignore` and `forget` first remove the ID from both.
  Source: inferred from `SlashCmdList.LOOTFILTERFOREVER` · Status: inferred
- R-06 Lists can be edited only with slash commands; the window shows counts and a Clear button that
  empties both lists.
  Source: inferred from `BuildWindow()` · Status: inferred · Code: `BuildWindow()`

### Configurable rules

- R-07 Quality rule: an item of quality `>= db.minQuality` is taken (default 2, Uncommon).
  Source: inferred from `DEFAULTS` · Status: inferred · Code: `Decide()`
- R-08 Profession materials (classes Tradegoods 7, Recipe 9, Gem 3, Reagent 5) are taken when
  `db.mats` is on.
  Source: inferred from `MATS_CLASS` · Status: inferred · Code: `Decide()`
- R-09 Price rule: the threshold is per unit, never per stack, so a stack of cheap items is left
  even when the stack is worth more than the threshold. Default 1000 copper (10 silver).
  Source: inferred from `CHANGELOG.md` 1.1.0 · Status: inferred · Code: `Decide()`
- R-10 With the price rule on, an item whose info is not cached yet is taken.
  Source: interview 2026-11-06 · Status: confirmed (2026-11-06) · Code: `Decide()`
- R-17 A price threshold of 0 takes every item, unsellable ones (vendor price 0) included.
  Source: interview 2026-11-06 · Status: confirmed (2026-11-06) · Code: `Decide()`
- R-11 Stack fill: an item is taken only when its whole quantity fits into existing partial stacks;
  several slots of the same item on one corpse share that room in slot order.
  Source: inferred from `StackRoom()` · Status: inferred · Code: `StackRoom()`, `Decide()`

### Loot window

- R-12 Shift while looting lets the client take everything; Ctrl opens the window untouched; both
  bypass the filter and the report.
  Source: inferred from `HandleLoot()` · Status: inferred · Code: `HandleLoot()`
- R-13 A managed window closes only after `LOOT_OPENED` and once every wanted slot has cleared, and
  only when `db.close` is on. Nothing wanted means it closes right at `LOOT_OPENED`.
  Source: inferred from `TryClose()` · Status: inferred · Code: `TryClose()`
- R-14 The report lists only slots decided "leave", as item links with `×N` for stacks above 1.
  Source: inferred from `HandleLoot()` · Status: inferred · Code: `HandleLoot()`

### Input

- R-15 `/lootfilter value N` takes silver, accepts a comma or a dot as the decimal separator, and
  rounds to whole copper. `quality` accepts 0–4 and floors fractions.
  Source: inferred from `SlashCmdList.LOOTFILTERFOREVER` · Status: inferred
- R-16 In the window's price fields, silver and copper are clamped to 99 and an empty field counts
  as 0; the value is committed when a field loses focus.
  Source: inferred from `CommitPrice()` · Status: inferred · Code: `CommitPrice()`

## Invariants

- I-01 The addon never turns Auto Loot on for a player who had it off; it restores the CVar only
  when `db.turnedOffAutoLoot` says it switched it off. Enforced by `SyncAutoLootCVar()`.
  Source: interview 2026-11-06 · Status: confirmed (2026-11-06) · Code: `SyncAutoLootCVar()`
- I-02 The filter runs at most once per loot window, whichever of `LOOT_READY` and `LOOT_OPENED`
  arrives first. Enforced by the `handled` flag, reset on `LOOT_CLOSED`.
  Source: inferred from `HandleLoot()` · Status: inferred · Code: `HandleLoot()`
- I-03 Upgrades keep user choices: on load only `nil` keys are filled from `DEFAULTS`. A key whose
  meaning changes is renamed and the old key cleared on load (`minValue` → `unitPrice`).
  Source: inferred from `CLAUDE.md` · Status: inferred
- I-04 `npending` equals the number of wanted slots not yet cleared; `LOOT_SLOT_CLEARED` counts only
  slots in `pending`.
  Source: inferred from the event handler · Status: inferred
- I-05 Every setting change, from the window or a slash command, ends with `Refresh()`, so the window
  never shows stale values.
  Source: inferred from `Refresh()` · Status: inferred · Code: `Refresh()`
