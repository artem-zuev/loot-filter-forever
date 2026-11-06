# LootFilter Forever

A loot filter for **World of Warcraft: Forever**. When you loot, LootFilter Forever takes only what you want
and closes the loot window. Everything else stays on the corpse, and a chat line tells you what was left.

> Status: 1.2.0 (formerly LootSieve). The in-game text is English, or Russian on a Russian game client.

## What it takes

Always:

- money and currencies
- quest items (including items that start a quest), bags and keys
- items on your **always** list

Depending on settings (defaults in brackets):

| Rule | Default |
| --- | --- |
| Items of this quality and above | Uncommon (green) and above |
| Profession materials: trade goods, gems, recipes, reagents | on |
| Items that sell to a vendor for at least this much **per unit** | on, 10 silver |
| Items that fit into a partial stack you already carry, so they need no new bag slot | on |

Items on your **never** list are always left, whatever the other rules say.

Slots the game locks (group loot rolls, another player's quest item) are never touched.

## Controls

| While looting | Effect |
| --- | --- |
| no modifier | filter applies |
| **Shift** | take everything (the game's normal auto loot) |
| **Ctrl** | open the loot window untouched |

LootFilter Forever turns the game's **Auto Loot** option off while it is enabled; otherwise the client
would take everything before an addon can act. Disabling LootFilter Forever turns Auto Loot back on.

## Settings

Open the settings window with `/lootfilter`, or from *Esc → Options → AddOns → LootFilter Forever*.

The window has:

- an on/off switch
- quality buttons, from Poor (grey) to Epic (purple)
- the per-unit vendor price, as gold, silver and copper fields
- check boxes for profession materials, stack fill, closing the loot window and the chat report
- always/never list counts and a Clear button

Slash commands:

| Command | Effect |
| --- | --- |
| `/lootfilter` | open the settings window |
| `/lootfilter help` | print status and commands |
| `/lootfilter on` / `/lootfilter off` | enable or disable |
| `/lootfilter quality 0-4` | minimum quality (0 grey, 1 white, 2 green, 3 blue, 4 purple) |
| `/lootfilter value N` | per-unit price threshold in silver; decimals allowed (`0.05` = 5 copper) |
| `/lootfilter add [item]` | always take this item (shift-click a link, or give an item ID) |
| `/lootfilter ignore [item]` | never take this item |
| `/lootfilter forget [item]` | remove the item from both lists |
| `/lootfilter list` | print both lists |

`/lf` is an alias for `/lootfilter`.

## Installation

Copy the `LootFilterForever` folder (the one that contains `LootFilterForever.toc`) into the game's AddOns folder:

- macOS: `/Applications/World of Warcraft/_forever_/Interface/AddOns`
- Windows: `World of Warcraft\_forever_\Interface\AddOns`

The Battle.net launcher can open the game folder: *WoW Forever → gear icon → Show in Finder/Explorer*.

## Compatibility

- Built for the WoW Forever client (TOC `## Interface: 16001`).
- **EllesmereUI:** turn off its *Quick Loot* option (it loots every slot); LootFilter Forever warns at login
  if it is on. EllesmereUI's *Auto Sell Junk* complements LootFilter Forever and can stay on.
- Any other addon that auto-loots every slot will defeat the filter.
- Upgrading from LootSieve: delete the old `Interface/AddOns/LootSieve` folder; otherwise both
  copies loot at once. The addon warns at login if LootSieve is still loaded. Settings are not
  carried over.

## Development

```
LootFilterForever/          the addon as shipped (TOC, Lua, icon)
art/                logo source for CurseForge (not shipped)
tests/              simulation tests against stubbed WoW APIs
docs/               architecture notes and CurseForge publishing guide
CLAUDE.md           context and conventions for working on the code
```

Run the tests from the repository root with Lua 5.1 or LuaJIT:

```sh
luajit tests/run.lua
```

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for how the addon works and
[docs/CURSEFORGE.md](docs/CURSEFORGE.md) for publishing.
