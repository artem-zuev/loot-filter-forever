# 0001: The addon owns the Auto Loot CVar

Status: Accepted
Date: 2026-11-06
Decision-makers: Artem (interview 2026-11-06)

## Context

With the game's Auto Loot (`autoLootDefault`) on, the client loots every slot before any
`LOOT_READY` handler can choose, so a filter cannot work. Asking players to turn it off by hand is
error-prone, and turning it on again for a player who never used it would change their game.

## Decision

While the addon is enabled, `SyncAutoLootCVar()` sets `autoLootDefault` to 0 at login and on every
enable, and records `db.turnedOffAutoLoot = true`. When the addon is disabled, it restores the CVar
to 1 only if that flag is set, then clears it. Shift while looting stays the way to take everything,
through the client's own modifier behaviour.

## Consequences

- Filtering works out of the box, with one chat notice at login.
- A player who never had Auto Loot keeps it off after disabling the addon.
- Re-enabling Auto Loot in the game options mid-session silently disables filtering until the next
  login or toggle (GOTCHAS G-01); a `CVAR_UPDATE` re-sync would close that gap.
- Uninstalling the addon without disabling it first leaves Auto Loot off.
