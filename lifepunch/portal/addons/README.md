# Addons

Purpose: manage DXRP addon packages and their revisions.

Observed Addons list fields:

- Name
- Visibility
- Price
- Revisions

Observed LifePunch addon packages:

- Additional Drop Locations
- Advanced Drug Processing
- AK-47
- Bitcoin Mining
- Double-Barreled Shotgun
- Hacker Job

Observed status:

- Visibility: Private
- Price: Free
- Revision counts visible per addon

Operational rules:

- Addon package source belongs in `../../addons`.
- Generated publish staging must preserve `Assets/addons/lifepunch/<ident>` and `Code/Addons/lifepunch/<ident>`.
- Publishing a revision is separate from attaching or pinning that revision in the gamemode.
- LifePunch credits and ownership must remain attached to LifePunch addon packages.

Portal confirmation needed:

- Addon detail fields.
- Revision publish fields.
- Content row editor fields.
- Whether one addon package can safely own multiple content rows.
- Visibility/release requirements before public DXRP network release.
