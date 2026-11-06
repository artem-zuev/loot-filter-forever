# 0003: Own settings window, verified templates only

Status: Accepted
Date: 2026-11-06
Decision-makers: Artem (interview 2026-11-06)

## Context

The WoW Forever client is retail-based, but it is not known which retail frame templates and
Settings controls exist there. A missing template is a Lua error at build time, which the test
stubs cannot reveal. EllesmereUI, which runs on this client, uses only a few templates and opens its
own window from the Blizzard Settings list.

## Decision

Settings live in an addon-owned window (`LootFilterForeverOptions`) built lazily from plain
`Button`, `EditBox` and texture widgets plus the three templates confirmed on the client:
`BackdropTemplate`, `UIPanelButtonTemplate`, `UIPanelCloseButton`. The look copies EllesmereUI
(flat dark panels, 1 px borders, teal accent). The Blizzard *Options → AddOns* entry is a stub
canvas page whose button hides the Settings panel and opens the window on the next frame. The test
stub's `CreateFrame` rejects every other template.

## Consequences

- No dependency on retail Settings controls that may differ on this client.
- Checkboxes, the quality selector and price inputs are hand-made and need their own refreshers.
- Adding a template requires an in-game check first, then widening the stub allow-list.
