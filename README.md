# MaelstromBar

A 5-square bar that tracks **Maelstrom Weapon** stacks for Enhancement Shamans, Retail-style. Built for the **World of Warcraft: Forever (Classic+)** client. Standalone: no libraries or other addons required.

Author: **Petitcorps**

## Preview

![MaelstromBar: 0 to 5 stacks, and the glow on the Lightning Bolt button at 5 stacks](assets/preview.png)

Default look: blue squares for 1 to 4 stacks, light cyan at 5 stacks, and a bright golden pulsing glow on the Lightning Bolt button when you reach 5. Every color is configurable in the options panel.

## Features

- 5 squares that fill up with your stacks, with a different color at 5 stacks.
- Real-time refresh: aura events are backed by a fast polling loop (~20 readings per second), even when the client throttles aura events or hides them in combat.
- Shown with at least 1 stack or in combat, or always (option).
- Movable through the interface **Edit Mode** if your client has one, otherwise with `/mw move`.
- Fully resizable: **square width, height and spacing** (options panel or `/mw size`), on top of the global **scale**.
- Configurable **background color**, and an optional **stack count** displayed in the middle of the bar (`/mw count`).
- **Glow** on your Lightning Bolt action-bar button at 5 stacks (option; macros with `#showtooltip`, `/cast`, `/use` or `/castsequence` are supported).
- Options panel in the AddOns menu: colors, size, scale, glow, test.
- Works in every client language (the buff is detected by spell ID 408505, with a localized-name fallback).
- **Works in combat** on clients that hide player auras from addons ("secret values"): the stacks are read through Blizzard's Cooldown Manager (see below), with the combat log as a fallback — aura events carry the stack count and need no configuration.

## In combat: the Cooldown Manager

On recent clients, addons can no longer read the player's buffs during combat. MaelstromBar gets around this in two ways:

- Primarily, it borrows the stack count from the **Maelstrom Weapon icon of Blizzard's Cooldown Manager**, so that buff should stay in the Cooldown Manager's tracked buffs.
- If that icon cannot be read, it falls back to the **combat log**: aura events (`SPELL_AURA_APPLIED_DOSE`, `SPELL_AURA_REMOVED_DOSE`…) carry the stack count and do not go through the aura API. This needs no configuration; out of combat, the authoritative aura read resynchronizes the count.

- On login, the addon enables the Cooldown Manager if needed and checks that Maelstrom Weapon is tracked. It does **not** modify the tracked buffs by itself: writing into the Cooldown Manager's settings from an addon taints Blizzard's code and causes errors in combat. Add Maelstrom Weapon to the tracked buffs by hand: the options panel's *Open the Cooldown Manager settings* button takes you right there (Options, Advanced category, Advanced settings window, Enhancements section).
- If the buff is not tracked, the bar shows a **red warning** underneath it — but only when it is certain (the buff must be active while the Cooldown Manager's icon is missing; with no buff active, the icon may simply not exist yet, especially with the Controller UI, so the check stays silent and retries). The warning can also be disabled: `/mw warn` or the checkbox in the options panel. Add Maelstrom Weapon to the tracked buffs in the Cooldown Manager settings, or type `/mw setup` to check again and see details.
- The action-bar glow at 5 stacks works in combat too: like the squares, it is driven directly by the hidden stack count.

## Installation

Copy the `MaelstromBar` folder into `World of Warcraft/_forever_/Interface/AddOns/`, then `/reload` or restart the game.
If the addon is flagged as out of date, tick "Load out of date AddOns".

## Options

**Options > AddOns > MaelstromBar**, or `/mw options`.

The panel starts with a **Cooldown Manager** section: it shows whether Maelstrom Weapon is tracked (required to read the stacks in combat) and guides you through the setup. The addon can enable the Cooldown Manager itself, but the tracked buffs must be ticked by hand in the game's options — the panel tells you exactly what to do, with a *Check again* button.

The bar can be resized in two ways, which combine:

- **Size** (square width, square height, spacing between squares): the total length of the bar follows from the square width and the spacing. In the options panel ("Size" section) or with `/mw size`.
- **Scale** (`/mw scale`): multiplies the whole bar, position included.

## Slash commands

| Command | Effect |
|---|---|
| `/mw options` | Open the options panel |
| `/mw move` / `/mw lock` | Unlock / lock the bar so you can move it |
| `/mw always` | Always show the bar, on/off |
| `/mw warn` | Red Cooldown Manager warning under the bar, on/off |
| `/mw color R G B` | Color of stacks 1 to 4 (values from 0 to 1) |
| `/mw color full R G B` | Color at 5 stacks |
| `/mw color bg R G B` | Background color of the bar |
| `/mw count` | Stack count in the middle of the bar, on/off |
| `/mw size width height [spacing]` | Square size in pixels (10-80 x 6-60, spacing 0-30) |
| `/mw scale 0.5-3` | Bar scale |
| `/mw glow` | Action-bar glow on/off |
| `/mw glowspell name or ID` | Spell to highlight (empty = Lightning Bolt) |
| `/mw glowframe FrameName` | Add or remove a frame to highlight; no argument: list; `clear`: remove all |
| `/mw glowscan` | List the buttons the addon can currently highlight (diagnostic) |
| `/mw test 0-5` | Simulate stacks to check the display (`0` = stop) |
| `/mw aura BuffName` | Buff name to track, if detection by ID fails |
| `/mw reset` | Reset the position and the size |
| `/mw setup` | Check the Cooldown Manager and the tracking of Maelstrom Weapon (out of combat) |
| `/mw log` | Show Lua errors recorded from the whole client; `clear`: wipe the log |
| `/mw testerror` | Trigger a deliberate error, to check that `/mw log` records it |
| `/mw debug` | List active buffs (name, stacks, ID) |

## Troubleshooting

- **A Lua error flashed by and you missed it:** type `/mw log` — errors from the whole client (including Blizzard's) are recorded and can be read back, with the time, the repeat count and the call stack.
- **The bar stays empty in combat:** the stacks are read through the Cooldown Manager first, then through the combat log (no configuration). If both fail, a chat message during combat says which path failed. Make sure Maelstrom Weapon is in the Cooldown Manager's tracked buffs — the options panel shows the status and how to fix it — then type `/mw setup`.
- **The bar stays empty out of combat too:** with stacks active, type `/mw debug` and check that the buff shows up. If it has another name, use `/mw aura "exact name"`.
- **No glow:** make sure the spell is on an action bar, then try `/mw test 5`. A button bound to a macro works too (`#showtooltip` macros, `/cast`, `/use`, `/castsequence`). Buttons outside the known bars (Controller UI, other addons) are found by a global scan; type `/mw glowscan` to see what is detected. For anything still missed, use `/mw glowframe FrameName` (find the name with `/fstack`).
- **The addon does not show up:** wrong folder, or "Load out of date AddOns" is not ticked.

## License

Open source, released under the [MIT License](LICENSE). Copyright (c) 2026 Petitcorps.
