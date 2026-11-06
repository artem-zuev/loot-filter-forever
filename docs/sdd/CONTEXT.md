# LootFilter Forever

## Purpose

A World of Warcraft: Forever addon that decides, slot by slot, what to take from every loot window,
loots only those slots, closes the window and reports in chat what it left. It is for players who
want clean bags without picking loot by hand. It ships as one folder (`LootFilterForever/`) and is
distributed through CurseForge.

## Neighbours

| System | Direction | Via | Notes |
|---|---|---|---|
| WoW Forever client (12.x API family) | upstream | events `LOOT_READY`, `LOOT_OPENED`, `LOOT_SLOT_CLEARED`, `LOOT_CLOSED`; loot, item and container APIs | the only data source; behaviour differs from the test stubs in ways only an in-game check shows |
| Client CVar `autoLootDefault` | both | `C_CVar` | the addon switches it off and owes a restore (see [ADR 0001](adr/0001-addon-owns-auto-loot-cvar.md)) |
| Blizzard Settings panel | downstream | `Settings.RegisterCanvasLayoutCategory` | a stub page whose only button opens the addon's own window |
| EllesmereUI | upstream (read) | global `EllesmereUIDB` | Quick Loot defeats the filter, so the addon warns at login; Auto Sell Junk is complementary |
| LootSieve (former name of this addon) | upstream (read) | `IsAddOnLoaded("LootSieve")` | both copies would loot at once, so the addon warns at login |
| CurseForge | downstream | manual zip upload | flavor "Forever"; see [CURSEFORGE.md](../CURSEFORGE.md) |

## Non-standard decisions

- Everything lives in one Lua file with no libraries and only `local` functions; the only globals are
  the saved variables, the slash command entries and the window frame name.
  Source: inferred from `LootFilterForever/LootFilterForever.lua` · Status: inferred
- The addon turns the game's Auto Loot off itself and restores it only if it was the one that
  turned it off ([ADR 0001](adr/0001-addon-owns-auto-loot-cvar.md)).
  Source: interview 2026-11-06 · Status: confirmed (2026-11-06) · Code: `SyncAutoLootCVar()`
- Each slot gets one of three outcomes: take, leave and report, or ignore silently. When data is
  missing the addon errs towards taking ([ADR 0002](adr/0002-three-way-decision-errs-to-take.md)).
  Source: interview 2026-11-06 · Status: confirmed (2026-11-06) · Code: `Decide()`
- Settings live in an addon-owned window built from custom widgets and the three frame templates
  verified on this client, not from Blizzard Settings controls
  ([ADR 0003](adr/0003-own-settings-window-verified-templates.md)).
  Source: interview 2026-11-06 · Status: confirmed (2026-11-06) · Code: `BuildWindow()`
- The addon ships a plain `LootFilterForever.toc` with `## Interface: 16001`, not the
  `<Name>_Camelot.toc` + `AllowLoadGameType: camelot` pair that EllesmereUI uses on this client. The
  fallback, if the client ever refuses the plain TOC, is to rename it to `_Camelot.toc`. The plain
  TOC is verified to load in game.
  Source: interview 2026-11-06 · Status: confirmed (2026-11-06)
- The name is "LootFilter Forever", not "LootFilter": that name is taken on CurseForge by an older
  Retail/Classic addon, project names there must be unique, and the folder would clash with it.
  Before 1.2.0 the project was called LootSieve.
  Source: inferred from `CHANGELOG.md` 1.2.0 · Status: inferred
- Saved variables of the former LootSieve addon (`LootSieveDB`) are deliberately not migrated.
  Source: inferred from `CHANGELOG.md` 1.2.0 · Status: inferred
- Everything that touches looting is the same code path whatever triggered the window: a mob, a
  gathering node or a container.
  Source: inferred from `HandleLoot()` · Status: inferred · Code: `HandleLoot()`

## Decisions

| ADR | Title | Status |
|---|---|---|
| [0001](adr/0001-addon-owns-auto-loot-cvar.md) | The addon owns the Auto Loot CVar | Accepted |
| [0002](adr/0002-three-way-decision-errs-to-take.md) | Three-way slot decision that errs towards taking | Accepted |
| [0003](adr/0003-own-settings-window-verified-templates.md) | Own settings window, verified templates only | Accepted |
