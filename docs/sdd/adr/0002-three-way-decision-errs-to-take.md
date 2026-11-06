# 0002: Three-way slot decision that errs towards taking

Status: Accepted
Date: 2026-11-06
Decision-makers: Artem (interview 2026-11-06)

## Context

Some slots cannot be decided on the data at hand: locked slots (rolls, other players' quest items)
are not ours to take, and items whose info is not cached yet have no vendor price. Leaving a
valuable item behind costs the player more than one extra item in the bags.

## Decision

`Decide(slot)` returns `true` (take), `false` (leave and report) or `nil` (ignore silently). Rules
are checked in a fixed order and the first match wins: currency and money, the never list, the
always list, quest items and containers, then the configurable rules. Locked slots return `nil`.
With the price rule on, an item whose price is unknown is taken.

## Consequences

- The report never lists slots the player could not have taken.
- A first loot of a new item may take something the price rule would later leave.
- Every new rule must fit into the order and keep the three-way contract; `HandleLoot()` relies on
  `false` vs `nil` to decide what to report.
