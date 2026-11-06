# Roadmap

## Open items

In rough priority order:

2. **License.** Pick one (MIT suggested) and add `LICENSE`.
3. **Screenshots** for CurseForge. The logo is `art/logo.png`.
4. **Publish.** Create the CurseForge project and upload; see [CURSEFORGE.md](CURSEFORGE.md).
5. **Automation (optional).** A GitHub repo with the BigWigsMods packager, `.pkgmeta` and
   `## X-Curse-Project-ID`.
6. **Feature ideas:**
  - re-sync Auto Loot on `CVAR_UPDATE`;
  - Alt-click an item (bag or loot window) to add it to the always or never list;
  - show and edit the lists in the window;
  - per-character settings.

## Known limitations

- Filtering stops if Auto Loot is switched back on mid-session in the game options. It resumes at
  the next login or addon toggle.
- The loot window stays open when a wanted slot cannot be looted: a bind-on-pickup confirmation, a
  full inventory, or a roll. This is by design.
- Locked slots (rolls, other players' quest items) are neither taken nor reported.
- With the price rule on, items whose info is not cached yet are taken (safe default).
- Prices are vendor sell prices only, with no auction data.
- The lists can only be edited with slash commands; the window shows counts and a Clear button.
- `/lf` may clash with another addon's command; `/lootfilter` is the primary one.
