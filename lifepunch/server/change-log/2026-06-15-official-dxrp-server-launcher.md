# Server Change Record — Official launcher migration

Date: 2026-06-15
Server: lifepunchmainserver
Portal display name: LifePunch Official | 70p
Changed by: Bloodwave / VENGEANCE agent
Reviewed by: (owner)

## Portal Area

- Page: lifepunchnet on-box launcher (not portal UI)
- Field or action: Replace `sbox-server.exe +game dxura.rp` with `dotnet run dxrp-server.cs`
- Risk: high (production pulse / player visibility)

## Change

Before:

```text
sbox-server.exe +port 27015 +game dxura.rp +authorize <token>
→ This game has no code archive! (INACTIVE on portal)
```

After:

```text
dotnet run dxrp-server.cs --token <Official portal token>
→ clone dxrp, pull addons API, +game local rp.sbproj, +port 27015
```

Reason: Cloud `dxura.rp` ident no longer provides dedicated-server code archive; Dev (Server 2) already works via Dxura launcher.

## Approval

- Owner approval required: yes
- Owner approval received: pending deploy on lifepunchnet
- Approval notes: Repo wrappers in lifepunch/server/dxrp-host/

## Test And Verification

- Tested on lifepunchdevelopment first: yes (Server 2 already on dxrp-server.cs)
- Validation performed: Deploy scripts + config example with +port 27015
- Observed result: pending Official cutover on box

## Rollback

Rollback steps:

```text
Stop dotnet dxrp-server session; re-run legacy bat only if Dxura republishes dxura.rp code archive.
```

Rollback owner: Bloodwave

## Evidence

- Repo: lifepunch/server/dxrp-host/
- Related: lifepunch/server/dxrp-host/README.md
