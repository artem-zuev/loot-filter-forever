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

## Automatic releases

`.github/workflows/release.yml` uploads a file when a `v*` tag is pushed to GitHub:

1. Bump `## Version` in the TOC, add the matching `## [x.y.z]` section to `CHANGELOG.md`, commit
   and push.
2. `git tag v1.3.0 && git push origin v1.3.0`. A `-beta` or `-alpha` suffix (`v1.3.0-beta1`)
   uploads that release type; any other tag is a Release.

The workflow:

- runs the tests;
- checks that the tag matches `## Version`;
- takes that version's `CHANGELOG.md` section as the file changelog;
- finds the CurseForge game version of type 88568 ("WoW Forever") whose `apiVersion` equals
  `## Interface` (16001 is "1.60.1", ID 17053);
- zips only `LootFilterForever/` and uploads it to the project in `## X-Curse-Project-ID` (1786908).

Any failed check stops it before the upload. When Forever moves to a new interface, CurseForge must
list it first, otherwise the run stops with "CurseForge has no WoW Forever version for interface N".

The API token lives in the `CF_API_TOKEN` repository secret (GitHub → Settings → Secrets and
variables → Actions). Tokens are created at <https://authors.curseforge.com/#/settings/api-tokens>.
The upload API is documented at
<https://support.curseforge.com/en/support/solutions/articles/9000197321-curseforge-upload-api>.

The BigWigsMods packager was not used: it ships every tracked file unless `.pkgmeta` ignores it, and
the addon sits in a subfolder of the repository.

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
- **Mage scrolls:** on a mage, the unidentified scrolls ("Scroll: CWAL" and the rest) for Comprehend Scroll
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
