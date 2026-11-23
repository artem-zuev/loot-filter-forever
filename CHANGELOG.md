# Changelog

All notable changes to LootFilter Forever. Versions follow the `## Version` line in `LootFilterForever/LootFilterForever.toc`.

## [1.4.0] - 2026-11-23

### Added
- Waylaid Crates: all 31 crates (the base "Waylaid Crate" and the labelled ones such as "Waylaid
  Crate: Apprentice Herbs") are now taken. You fill them with profession materials and hand them in
  for Merchant's Favor. The white ones are worth nothing to a vendor, so no other rule took them.
  The new *Waylaid Crates* check box is on by default, for every class.

## [1.3.0] - 2026-11-21

### Added
- Mage scrolls: a mage now takes the 17 unidentified scrolls ("Scroll: CWAL", "Scroll: KWYJIBO" and
  the rest) that Comprehend Scroll deciphers. They are white, sell for 15 copper and do not stack,
  so no other rule took them. The new *Mage scrolls* check box is on by default. Settings are
  account-wide, so the check box is dimmed on other classes, and they leave the scrolls.

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
