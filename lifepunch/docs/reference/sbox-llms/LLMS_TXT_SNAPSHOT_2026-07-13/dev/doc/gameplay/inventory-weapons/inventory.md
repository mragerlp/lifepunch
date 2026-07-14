# Inventory

Add a `BaseInventoryComponent` to your player and it can carry things. It keeps items in slots, remembers which one is deployed, and handles picking up, dropping and switching.

## Slots

`MaxSlots` sets how many slots there are, and `Behaviour` sets how they work:

| Behaviour | Description |
|-----------|-------------|
| **Hotbar** | One item per slot, like Rust or Minecraft. When an item's preferred slot is taken it goes to the first empty one. |
| **Buckets** | Slots are categories and any number of items share one, like GMod or Half-Life. Items always land in their preferred slot. |

Items ask for a slot with their `PreferredSlot` property, and sort within a bucket by `SlotOrder`.

## Picking things up

`PickupMode` controls how the inventory takes items lying in the world:

| Mode | Description |
|------|-------------|
| **None** | It doesn't. Call `PickupWorldItem` from your own code when you want one taken. |
| **Touch** | Walking near a world item picks it up, like GMod or Quake. |
| **Use** | The player presses use on the item to take it. |

With `AutoSwitchOnPickup` on, picking up something better than what's held deploys it. Better means a higher `Value`, which you set on each item.

Picking up a weapon the player already has doesn't give a second copy. The duplicate donates its ammo to the reserve instead.

## Loadouts

Turn the Loadout feature on to have starting gear. `StartingItems` is a list of prefabs given when the inventory starts, along with any `StartingAmmo`. Call `GiveLoadout()` yourself when you want to give it again, on respawn for example.

## Switching, dropping, removing

`Switch( item )` deploys an item, `Drop( item )` throws it out into the world, `Remove( item )` destroys it. Query what's held with `Items`, `ActiveItem`, `GetSlot( n )` and `GetItem<T>()`.

```csharp
var inventory = player.GetComponent<BaseInventoryComponent>();
var item = inventory.ActiveItem;

if ( item.IsValid() )
	Log.Info( $"Holding {item.DisplayName} in slot {item.Slot}" );
```

All of this is host authoritative. The owning client can call these too, they route through the host.

## Ammo

Reserve ammo lives on the inventory, not on the weapon, so two guns that share an ammo type share their reserve. An ammo type is a `BaseAmmoResource` asset with a name, an icon and a max reserve. Create one from the Asset Browser.

`GetAmmo`, `GiveAmmo` and `TakeAmmo` on the inventory read and change the pool.

## Making an item

`BaseInventoryItem` is anything an inventory can hold. On its own it's a pickup with a display name, an icon and a slot preference. Override its hooks to give it behaviour:

* `OnEquipped` / `OnHolstered` run on every peer when it's deployed or put away.
* `OnControl` runs each frame on the owning client while it's deployed. Read input here.
* `OnAdded` / `OnRemoved` run on the host when it enters or leaves an inventory.
* `OnDrop` places the item in the world when dropped. Return false to refuse the drop.

:::info
There's no built in inventory or hotbar UI. Build your own from `Items`, `GetSlot` and `ActiveItem`. They're synced and cheap enough to read from HUD code every frame.
:::
