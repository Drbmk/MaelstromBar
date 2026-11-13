# Changelog

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
