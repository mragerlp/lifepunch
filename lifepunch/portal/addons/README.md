# Addons

Purpose: manage DXRP addon packages and their revisions.

Public addon browser:

```text
https://dxrp.net/addons
```

Observed official/published addon example:

```text
https://dxrp.net/addons/019e4013-08a5-77d0-975c-df132345045e
```

Authenticated portal addon editor (UUID after `/portal/addons/` = canonical `dxrpAddonId` in `addons.json`):

```text
https://dxrp.net/portal/addons/019ee8ed-2bba-7f7a-8836-09b70b816722
```

LifePunch ULX (`lifepunchulx`): package slug and addon identifier are both `lifepunchulx`; portal UUID `019ee8ed-2bba-7f7a-8836-09b70b816722` (fresh-start package, Jun 2026). Legacy UUID `019e9cfa-3141-723c-a430-1a0e256472eb` is obsolete.

Example package: `Kevlar`.

Observed addon detail areas:

- Media/about area.
- `Add to Server` action.
- Metadata for content item count, servers using the addon, published time, updated time, package identifier, and revision/source links.
- Tabs for `About`, `Contents`, and `Code Explorer`.
- Code Explorer files such as `KevlarEntity.cs` and `KevlarService.cs`.

Observed Addons list fields:

- Name
- Visibility
- Price
- Revisions

Observed LifePunch addon packages:

- Additional Drop Locations
- Advanced Drug Processing
- AK-47
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

