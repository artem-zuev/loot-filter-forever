# Changelog

All notable changes to LootFilter Forever. Versions follow the `## Version` line in `LootFilterForever/LootFilterForever.toc`.

## [1.2.0] - 2026-11-06

### Changed
- Renamed from LootSieve to **LootFilter Forever**. The plain name "LootFilter" is already taken on
  CurseForge by an older Retail/Classic addon. The name changes are:

  | | Before | After |
  | --- | --- | --- |
  | Folder and TOC | `LootSieve` | `LootFilterForever` |
  | Saved variables | `LootSieveDB` | `LootFilterForeverDB` |
  | Slash commands | `/sieve`, `/ls` | `/lootfilter`, `/lf` |
  | Settings window frame | `LootSieveOptions` | `LootFilterForeverOptions` |
  | Chat prefix | `LootSieve:` | `LootFilter:` |

- Settings from LootSieve are not carried over, because saved variables belong to the old addon
  name.

### Added
- English localization. The addon follows the game client language: Russian on ruRU clients,
  English everywhere else.
- Addon icon in the game's AddOns list and in the settings window header.
- Login warning when the old LootSieve addon is still loaded. Two copies would loot at the same
  time.

## [1.1.0] - 2026-11-06

### Added
- Settings window (`/lootfilter`). It has quality buttons, a per-unit price field in gold, silver and
  copper, and check boxes for every option. It also shows the always/never list counts, with a Clear
  button.
- Entry in the game's *Options → AddOns* list, with a button that opens the settings window.
- Stack fill: an item that fits entirely into partial stacks already in the bags is taken, even when
  no other rule matches. Several slots of the same item on one corpse share the available room.
- `useValue` option to turn the price rule off.
- `/lootfilter help` (bare `/lootfilter` now opens the window).

### Changed
- The price threshold is now **per unit**, not per stack (`unitPrice`, default 10 silver). The 1.0
  per-stack setting (`minValue`) is discarded on load.

### Fixed
- Quality names in chat are lowercased correctly. Lua's `string.lower` does not handle Cyrillic, so
  separate tables are used.

## [1.0.0] - 2026-11-06

### Added
- Loot filter: money, currencies, quest items, bags and keys are always taken. Items are also taken
  by minimum quality, by profession materials, and by vendor value per stack (default 50 silver).
- Always/never item lists via slash commands.
- Turns the game's Auto Loot off while enabled and restores it when disabled.
- Shift while looting takes everything; Ctrl opens the window untouched.
- Closes the loot window once every wanted slot is looted, and reports skipped items in chat.
- Warns at login when EllesmereUI's Quick Loot is enabled.
