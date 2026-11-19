# MaelstromBar

A 5-square bar that tracks **Maelstrom Weapon** stacks for Enhancement Shamans, Retail-style. Built for the **World of Warcraft: Forever (Classic+)** client. Standalone: no libraries or other addons required.

Author: **Petitcorps**

## Preview

![MaelstromBar: 0 to 5 stacks, and the glow on the Lightning Bolt button at 5 stacks](assets/preview.png)

Default look: blue squares for 1 to 4 stacks, light cyan at 5 stacks, and a bright golden pulsing glow on the Lightning Bolt button when you reach 5. Every color is configurable in the options panel.

## Features

- 5 squares that fill up with your stacks, with a different color at 5 stacks.
- **Works in combat with zero configuration**: the stacks are displayed by the game engine itself (see below) — no setup, no other addon, nothing to tick in the game's options.
- Real-time refresh out of combat: aura events are backed by a fast polling loop (~20 readings per second), even when the client throttles aura events.
- Shown with at least 1 stack or in combat, or always (option).
- Movable through the interface **Edit Mode** if your client has one, otherwise with `/mw move`.
- Fully resizable: **square width, height and spacing** (options panel or `/mw size`), on top of the global **scale**.
- Configurable **background color**, and an optional **stack count** displayed above the bar — its position is adjustable: above, centered or below (`/mw count pos`), fine-tuned with an offset, or simply **dragged with the mouse in Edit Mode**.
- **Glow** on your Lightning Bolt action-bar button at 5 stacks (option; macros with `#showtooltip`, `/cast`, `/use` or `/castsequence` are supported). It works in combat too, driven by the game engine.
- Options panel in the AddOns menu: colors, size, scale, glow, test.
- Works in every client language (the buff is detected by spell ID 408505, with a localized-name fallback).

## In combat: the game engine displays the stacks

On recent clients, addons can no longer read the player's buffs during combat ("secret values"). MaelstromBar does not fight this: it asks the **game engine itself** to display the stacks, using the same mechanism the client uses for its own aura UI.

- In combat, the squares, the stack count and the action-bar glow at 5 stacks are driven directly by the engine. Nothing to configure — the Cooldown Manager is not needed, and the addon never touches the game's settings.
- Out of combat, the addon reads the auras directly, as it always has, and the display is identical.
- The combat display is prepared out of combat (that is when the client allows it to be created): if the addon was loaded during a fight, it is ready as soon as that fight ends.

## Installation

Copy the `MaelstromBar` folder into `World of Warcraft/_forever_/Interface/AddOns/`, then `/reload` or restart the game.
If the addon is flagged as out of date, tick "Load out of date AddOns".

## Options

**Options > AddOns > MaelstromBar**, or `/mw options`.

The panel starts with an **In combat** section: it shows whether the engine-driven combat display is active (green) or will be ready for the next fight. There is nothing else to do — the section is informational.

The bar can be resized in two ways, which combine:

- **Size** (square width, square height, spacing between squares): the total length of the bar follows from the square width and the spacing. In the options panel ("Size" section) or with `/mw size`.
- **Scale** (`/mw scale`): multiplies the whole bar, position included.

The stack count is positioned with `/mw count pos above|center|below` and `/mw count offset x y`, or by dragging it in Edit Mode (`/mw move`): grab the number, drop it where you want, and the position is saved.

## Slash commands

| Command | Effect |
|---|---|
| `/mw options` | Open the options panel |
| `/mw move` / `/mw lock` | Unlock / lock the bar (and the stack count) so you can move them |
| `/mw always` | Always show the bar, on/off |
| `/mw color R G B` | Color of stacks 1 to 4 (values from 0 to 1) |
| `/mw color full R G B` | Color at 5 stacks |
| `/mw color bg R G B` | Background color of the bar |
| `/mw count` | Stack count above the bar, on/off |
| `/mw count pos above\|center\|below` | Position of the count |
| `/mw count offset x y` | Fine offset of the count, in pixels |
| `/mw size width height [spacing]` | Square size in pixels (10-80 x 6-60, spacing 0-30) |
| `/mw scale 0.5-3` | Bar scale |
| `/mw glow` | Action-bar glow on/off |
| `/mw glowspell name or ID` | Spell to highlight (empty = Lightning Bolt) |
| `/mw glowframe FrameName` | Add or remove a frame to highlight; no argument: list; `clear`: remove all |
| `/mw glowscan` | List the buttons the addon can currently highlight (diagnostic) |
| `/mw test 0-5` | Simulate stacks to check the display (`0` = stop) |
| `/mw aura BuffName` | Buff name to track, if detection by ID fails |
| `/mw reset` | Reset the position and the size |
| `/mw setup` | Status of the combat display |
| `/mw log` | Show Lua errors recorded from the whole client; `clear`: wipe the log |
| `/mw testerror` | Trigger a deliberate error, to check that `/mw log` records it |
| `/mw debug` | List active buffs (name, stacks, ID) |

## Troubleshooting

- **A Lua error flashed by and you missed it:** type `/mw log` — errors from the whole client (including Blizzard's) are recorded and can be read back, with the time, the repeat count and the call stack.
- **The bar stays empty in combat:** the combat display is built out of combat. If the addon was loaded during a fight, it becomes ready at the end of that fight. Type `/mw setup` to see the status; `/mw native retry` forces a rebuild out of combat.
- **The bar stays empty out of combat too:** with stacks active, type `/mw debug` and check that the buff shows up. If it has another name, use `/mw aura "exact name"`.
- **No glow:** make sure the spell is on an action bar, then try `/mw test 5`. A button bound to a macro works too (`#showtooltip` macros, `/cast`, `/use`, `/castsequence`). Buttons outside the known bars (Controller UI, other addons) are found by a global scan; type `/mw glowscan` to see what is detected. For anything still missed, use `/mw glowframe FrameName` (find the name with `/fstack`). A glow that appears while you are already in combat gets its combat driver at the end of that fight.
- **The addon does not show up:** wrong folder, or "Load out of date AddOns" is not ticked.

## License

Open source, released under the [MIT License](LICENSE). Copyright (c) 2026 Petitcorps.
