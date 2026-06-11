# Red — Hacker Job build runbook (VENGEANCE)

**Portal:** `019e448c-4958-77d1-84b7-c7ec3f1bc328` · **dev gamemode only** until Opus sign-off.

**First win:** **H1** — UI + bots (passable after sync). **H2** — world CRT entity (prefab + ModelDoc in editor).

Canon: `HACKER_JOB_SPEC.md` · `TERMINAL_BRAND_MATRIX.md` · `hackerjob/docs/HACKER_JOB_PLAYTEST.md`

---

## Step 0 — Sync + smoke (~10 min)

```powershell
powershell -File lifepunch/scripts/Sync-LifePunchAddonsToDxrp.ps1 -Addon hackerjob
# adminmenu is code-only — mirror Code/Addons/lifepunch/adminmenu if sync script skips it
```

Editor play (host). Close DXRP pause/inventory so the terminal input receives keys.

```text
lifepunch_spawn_testbot Greg
lp_cornerman_ui
scan
hack <steamid>
```

**Puzzle answers:** `drain(wallet);` · `cornerman_bypass` · `1`

**Pass (H1):** Ops Console opens (960×640, session rail); Greg appears in `scan` (module or command); puzzle completes in TARGET; bypass stub prints. No money moved (Phase 1).

**Advanced UI smoke (no prefab):**

```text
lp_vengeance_ui
govdb
infil govdb-tax-01
```

---

## Step 1 — CRT mesh (~30 min)

```powershell
cd lifepunch\addons\scripts
powershell -File .\Seed-HackerTerminalCrt.ps1
```

Copies LifePunch-owned `computer.fbx` from the bitcoinmining CRT family into hackerjob (standard + advanced source folders). **Never** ship raw CS2 or third-party exports.

**ModelDoc (editor):**

| Tier | Open | Compile |
|------|------|---------|
| Standard (green) | `models/.../hacker-terminal/hacker-terminal.vmdl` | Assign materials → compile |
| Advanced (red) | `models/.../advanced-hacker-terminal/advanced-hacker-terminal.vmdl` | Duplicate materials with Vengeance red palette |

See `Assets/addons/lifepunch/hackerjob/models/lifepunch/hackerjob/*/MODEL_BUILD.md`.

---

## Step 2 — Prefabs (~45 min)

Clone `bitcoin-miner.prefab` wiring — strip mining components, keep **Rigidbody** + **BoxCollider**, add **HackerTerminalEntity** + CRT **ModelRenderer**.

**Details:** `hackerjob/docs/ENTITY_PREFAB_BUILD.md`

| Prefab | Dev spawn |
|--------|-----------|
| `entities/hacker-terminal/hacker-terminal.prefab` | `lp_spawn_hacker_terminal` |
| `entities/advanced-hacker-terminal/advanced-hacker-terminal.prefab` | `lp_spawn_advanced_hacker_terminal` |

**Pass (H2):** prefab spawns visible CRT (or placeholder mesh until materials); stand within 6m; interact opens `cornerman.exe` / `vengeance.exe`.

---

## Step 3 — Publish

```powershell
.\scripts\prepare-publish.ps1 -Addon hackerjob
```

Upload `Assets` + `Code` from `.dxrp-publish/upload/`. Pin on **LifePunch dev gamemode only** — not production.

---

## Step 4 — Opus (later)

Wallet debit/credit, job gate, server-validated puzzles — **do not move money in Phase 1.**

Green patch-handoff: Cornerman ships UI/puzzle stubs; Red owns world entity + publish. Re-sync before each editor session.

---

## Quick reference

| Command | Purpose |
|---------|---------|
| `lp_cornerman_ui` | H1 — green terminal UI (no prefab) |
| `lp_vengeance_ui` | Advanced UI smoke |
| `lp_spawn_hacker_terminal` | H2 — standard world entity |
| `lp_spawn_advanced_hacker_terminal` | H2 — red-tier world entity |
| `lifepunch_spawn_testbot Greg` | Scan/hack target |
