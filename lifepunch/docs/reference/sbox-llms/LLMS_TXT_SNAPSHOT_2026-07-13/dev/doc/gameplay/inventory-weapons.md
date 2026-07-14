# Inventory & Weapons

The engine ships with an inventory and weapon system, modelled loosely on Garry's Mod. It gives you pickups, slots, weapon switching, ammo, shooting and reloading without you having to build any of it.

There are three components:

* [BaseInventoryComponent](/dev/doc/gameplay/inventory-weapons/inventory) goes on your player. It holds items, tracks which one is deployed, and owns the reserve ammo pool.
* [BaseInventoryItem](/dev/doc/gameplay/inventory-weapons/inventory) is anything that can live in an inventory. Usable as-is for a simple pickup.
* [BaseCombatWeapon](/dev/doc/gameplay/inventory-weapons/weapons) builds on that to make guns, melee weapons and tools.

A working gun needs no code at all. Put a BaseCombatWeapon on a prefab, fill in the properties, and it shoots, reloads, runs dry and plays its effects. You subclass when you want it to behave differently.

Everything is networked. The host owns the truth, and the holding player predicts locally so firing feels instant.
