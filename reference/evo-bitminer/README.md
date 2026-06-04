# evo-bitminer (REFERENCE ONLY — DO NOT SHIP)

This folder holds the original Bitcoin Mining / Bitminer work that was built around
**evo's (SPL Mute network) cloud model**. It has been moved out of the publishable
LifePunch addon set and is kept here **purely as reference**.

## Why it's here and not shippable

- The bitminer **model + textures are evo's intellectual property**. LifePunch will not
  publish them as its own content. (As of 2026-06-04, evo's network is independent and
  their assets stay theirs unless/until a paid arrangement is made.)
- The model was served via `evorp.*` **cloud packages**, which cannot render on DXRP
  servers anyway: the server enforces `RestrictCloudOrg = "facepunch"`, so non-facepunch
  cloud packages never mount (this is why it showed up gray in-game).

## What is ours vs evo's

- **Ours (reusable for the in-house bitminer):** the code under
  `Code/Addons/lifepunch/bitcoinmining/` — `BitminerEntity.cs` (dual-build pattern),
  the terminal UI (`BitminerTerminal.razor` + host), and the mining logic. Plus the
  publish/scaffold learnings.
- **Evo's (do not reuse without permission):** the model geometry, materials, and
  textures referenced by `entities/bitminer/bitminer.prefab` and the `evorp.*` packages.

## The plan

Build a **LifePunch in-house bitminer**: reuse our code as the seed, pair it with a
**new model made in Blender** (a distinct design, not evo's), texture it self-contained
inside the addon (no cloud refs), and publish that as genuine LifePunch content.

## Removed from the active project on 2026-06-04

- Deleted the `bitcoinmining` entry from `lifepunch/addons/config/addons.json`
  (publish manifest) so it can no longer be staged/published.
- Removed the `evorp.bitminer1 / cryptominerfanbig / cryptominerfansmall`
  `PackageReferences` from `lifepunch/addons/addons.sbproj`.
- Unpin `lifepunch.bitcoinmining` from the LifePunch gamemode on the DXRP portal
  (manual portal action).
