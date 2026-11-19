# Changelog

## 1.5.0

- **In combat, the display is now powered by the game engine itself** ("does not track during combat" is fixed for good). On clients that hide player auras from addons, MaelstromBar no longer tries to read the stacks in combat: it lets the client's own aura engine fill the squares, write the stack count and light the glow — the same mechanism the game uses for its own UI. **Zero configuration**: the Cooldown Manager is not needed anymore, and the addon never touches the game's settings. Out of combat, nothing changes (direct aura reads, as always). The combat display is prepared out of combat, so if the addon loads during a fight, it is ready as soon as that fight ends.
- The **action-bar glow at 5 stacks** works in combat too, driven by the game engine the same way.
- New: the **background color** of the bar is configurable (options panel, "Bar background", or `/mw color bg R G B`).
- New: an optional **stack count** (options panel or `/mw count`), displayed above the bar by default and working in combat as well (written by the game engine). Its position is fully adjustable: `/mw count pos above|center|below`, a pixel offset with `/mw count offset x y`, or simply **drag it with the mouse in Edit Mode** (`/mw move`) — grab the number, drop it, the position is saved.
- New: the options panel opens with an **In combat** status section (green: the engine-driven display is ready) and now scrolls properly.
- Removed, obsolete with the engine-driven combat display: the Cooldown Manager reading path and its red warning, the combat-log fallback, and the commands `/mw warn`, `/mw cdmsettings`, `/mw cdminfo` and `/mw cleu`. `/mw setup` now reports the status of the combat display; `/mw native retry` forces a rebuild out of combat.

## 1.4.0

- Fixed: the red "Maelstrom Weapon is not tracked in the Cooldown Manager" warning could still appear while idling in town after login (seen with the Controller UI). The Cooldown Manager's icon apparently only exists while the buff is active on that UI, so an icon missing with no buff active is not proof that tracking is broken. The warning is now shown only when it is certain: the buff must be active (readable out of combat) while the icon is missing. When the buff is not active, the check stays silent and keeps retrying.
- New: the warning can be disabled entirely — `/mw warn` or a checkbox in the options panel ("Show the Cooldown Manager warning"). `/mw setup` still reports the tracking status even when the warning is off.
- Fixed: the action-bar glow now works for macros. The glow used to rely on a `GetMacroSpell` API that does not exist, so a button bound to a macro (for example with `#showtooltip`) could never light up. The macro text is now parsed: `/cast`, `/use`, `/castsequence`, several spells separated by `;` or `,`, and the French commands `/lancer` and `/utiliser` are supported; conditions in `[brackets]` are ignored.
- Fixed: the glow now also finds buttons that are not on a known action bar, such as the Controller UI's buttons: all global buttons are scanned (by action slot or by spell attribute) in addition to the known bars. New command `/mw glowscan` lists the buttons the addon can currently highlight, to diagnose what is found (or not) on non-standard UIs.

## 1.3.0

- Fixed: a false red warning ("Maelstrom Weapon is not tracked in the Cooldown Manager") right after login, typically with the Controller UI. The Cooldown Manager creates its icons late on that UI, so the login check concluded too early that the buff was not tracked; the warning only disappeared at the end of the first combat. The check now waits for the icons to actually exist (retries for about a minute after login) and keeps re-checking every 10 seconds while the warning is shown, so it also clears on its own as soon as the buff becomes tracked, without waiting for a combat. `/mw setup` still answers immediately.
- New: the size of the bar is now adjustable beyond the global scale: square width, square height and spacing between squares (the total length of the bar follows from them). Options panel ("Size" section with +/- steppers and a default-size button) or `/mw size <width> <height> [spacing]` (10-80, 6-60, 0-30). `/mw reset` and the reset button now restore the default size as well.

## 1.2.0

- New command: `/mw log` — Lua errors from the whole client (MaelstromBar's own, but also Blizzard code such as the Cooldown Manager taint) are now recorded to the SavedVariables with message, stack, time and repeat count, so they can be reviewed after the fact even without BugSack. `/mw log clear` wipes the log. The previous error handler (BugSack, Blizzard's error window) is still called, so nothing else changes.
- New command: `/mw testerror` — triggers a deliberate error to check that the log records it.
- `/mw` with no argument now prints the loaded version, to spot a stale copy of the addon in the game folder.

## 1.1.3

- Fixed a Blizzard UI error in combat ("attempt to compare a secret number value, execution tainted by MaelstromBar"): the addon no longer writes into the Cooldown Manager's settings (it used to add Maelstrom Weapon to the tracked buffs by itself) and no longer calls its cache-refreshing aura methods. Both contaminated data that Blizzard's own code re-read, crashing it on secret value comparisons. Add Maelstrom Weapon to the tracked buffs manually if needed; `/mw setup` now only checks the Cooldown Manager and tells you what to do.

## 1.1.2

- The bar and the glow now refresh in real time: aura events are backed by a fast polling loop (~20 readings per second), so stacks show up and drop immediately even when the client throttles aura events or hides them in combat.
- The Cooldown Manager icon used in combat is now cached between readings, making the in-combat path lighter.

## 1.1.1

- The glow on the action-bar button at 5 stacks now works in combat.
- The glow is larger and brighter: two rings, a colored veil over the button, and a faster pulse.
- French client: the Lightning Bolt spell is named "Eclair" (no accent) in the texts and in the glow detection.
- Removed the `/mw cdm` diagnostic command.

## 1.1

- The bar now works in combat on clients that hide player auras from addons: the stacks are read through the Maelstrom Weapon item of Blizzard's Cooldown Manager.
- On login, the addon enables the Cooldown Manager and tries to add Maelstrom Weapon to its tracked buffs.
- A red warning is shown under the bar when the buff is not tracked in the Cooldown Manager.
- New command: `/mw setup`.

## 1.0

- Initial release.
