# Official DXRP Addon Reference

Use public DXRP addon pages as the reference for how a finished LifePunch addon should appear after publishing.

Observed addon list:

```text
https://dxrp.net/addons
```

Observed published addon example:

```text
https://dxrp.net/addons/019e4013-08a5-77d0-975c-df132345045e
```

Example addon:

- Title: `Kevlar`
- Publisher: observed as `PiPsk` / similar in the public page UI.
- Page action: `Add to Server`.
- Detail metadata includes content count, server usage count, published time, updated time, package identifier, and source/revision links.
- Tabs include `About`, `Contents`, and `Code Explorer`.
- `Contents` shows one content item named `Kevlar`.
- `Code Explorer` shows code files including `KevlarEntity.cs` and `KevlarService.cs`.

Observed code shape from screenshots:

- Addon code lives under a package namespace, such as `Dxura.RP.Game.Addons.<Publisher>.<Addon>`.
- Entity behavior is separated from addon service/bootstrap behavior.
- Entity classes use S&box/DXRP-style attributes such as title, group, category, icon, property, and range metadata.
- Service classes use an addon service pattern and can log when the addon loads.

LifePunch rule:

- Treat the Kevlar page as a published-addon shape reference, not as AK47 implementation code.
- Do not copy code blindly from screenshots.
- For AK47, use the official DXRP weapon/M4A1 pattern for runtime behavior and the Kevlar page for public package/page structure.
- A LifePunch published addon should be readable in the public page, have clear content rows, and expose only the intended code/assets.
- Never reuse another server/community identifier, namespace, group, or package label. Public examples are reference patterns only; LifePunch code stays under `lifepunch` and LifePunch-owned namespaces.
