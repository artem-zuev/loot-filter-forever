# Publishing LootFilter Forever on CurseForge

## Before the first upload

- [ ] Confirm the current build in game: a few kills, a gathering node, Shift and Ctrl looting, and
  the settings window.
- [ ] Choose a license (MIT is the usual choice for small addons) and add `LICENSE`.
- [ ] Take two or three screenshots: the settings window, and the chat report after a kill.
- [ ] Check that the name **LootFilter Forever** is free on CurseForge. Project names must be unique.
- [ ] Bump `## Version` in `LootFilterForever/LootFilterForever.toc` and add a `CHANGELOG.md` entry.

## Create the project (once)

1. Go to <https://authors.curseforge.com>, sign in, choose **Create Project**, then
   **World of Warcraft**.
2. Fill in:
  - **Name:** LootFilter Forever
  - **Summary:** see below
  - **Description:** see below. It must be in English.
  - **License:** the one chosen above
  - **Main category:** Bags & Inventory
  - **Logo:** `art/logo.png` (1024×1024)
3. Submit. Project approval usually takes up to a day.

## Upload a file (every release)

1. Build the zip from the repository root. The archive must contain the `LootFilterForever/` folder at its
   root:

```sh
   zip -r LootFilterForever-<version>.zip LootFilterForever
```

2. Project dashboard → **Files** → **Upload File**.
3. Set the file fields:
  - **Release type:** Release (or Beta / Alpha for test builds)
  - **Game version:** the **Forever** flavor, version **1.60.1**, or whatever the current Forever
     version is
  - **Changelog:** paste the matching `CHANGELOG.md` section
4. The file shows *Under Review* until moderators approve it. A project needs at least one Release
   file before it appears in the CurseForge app.

## Optional: automatic releases

Host the repository on GitHub and use the BigWigsMods packager:

1. Add `## X-Curse-Project-ID: <numeric project id>` to the TOC. Use the number from the project
   page sidebar, not the slug.
2. Create an API token in the CurseForge author dashboard and store it as the `CF_API_KEY` repository
   secret.
3. Add a `.pkgmeta` file and a release workflow that runs `BigWigsMods/packager@v2` on tags.
4. Push a tag (`v1.2.0`) to release. `-beta` and `-alpha` suffixes map to those release types.

The packager reads the game version from `## Interface:`. Verify that it maps `16001` to the
Forever flavor before relying on it; if not, set the game version manually on the first upload.

## Listing text

### Summary

> Loot filter for WoW Forever: takes quest items, good gear, materials and valuables, and leaves
> the junk on the corpse.

### Description

```markdown
**LootFilter Forever** keeps your bags clean. When you loot, it takes only what you want, closes the loot
window, and tells you in chat what it left behind.

### Always taken
- Money and currencies
- Quest items (including items that start a quest), bags and keys
- Items on your *always* list

### Taken by your rules
- **Quality:** items of the chosen quality and above (default: Uncommon and above)
- **Profession materials:** ore, herbs, cloth, leather, meat, gems, recipes
- **Vendor value:** anything that sells for at least your threshold **per unit** (default: 10 silver)
- **Stack fill:** items that fit into a partial stack you already carry, so they never cost a new bag slot

Items on your *never* list always stay on the corpse. Group loot rolls and other players' quest
items are never touched.

### Controls
- **Shift** while looting: take everything
- **Ctrl** while looting: open the loot window untouched
- `/lootfilter`: settings window (also under *Options → AddOns*)
- `/lootfilter add [item]`, `/lootfilter ignore [item]`: manage the always and never lists
- `/lootfilter help`: every command

LootFilter Forever turns the game's Auto Loot option off while it is enabled, because the client would
otherwise take everything first. Disabling LootFilter Forever turns Auto Loot back on if it was on
before.

### Languages
English and Russian. The addon follows your game client's language.

### Compatibility
Made for World of Warcraft: Forever. If you use EllesmereUI, turn off its *Quick Loot* option;
LootFilter Forever warns you at login if it is on. Other addons that loot every slot automatically will
bypass the filter.
```
