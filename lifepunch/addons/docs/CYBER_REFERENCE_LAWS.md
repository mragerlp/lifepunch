# Cyber reference laws — DXRP production gate (owner law)

**Status:** HARD GATE — applies to every `lifepunchbitcoin` session and every future cyber lane.  
**Parent gate:** `ACTIVE_WORKSTREAM.md`  
**Digital machine canon:** `LIFEPUNCH_DIGITAL_MACHINE_STANDARD.md`  
**Brand canon:** `TERMINAL_BRAND_MATRIX.md`  
**Bible (populate on sign-off):** `BITCOIN_REFERENCE_IMPLEMENTATION.md`

> **Do not build the best Bitcoin miner. Build the standard that every future cyber profession will inherit.**  
> The quality of Hacker, Banker, Government, and every future lane is **capped** by the patterns established here.

---

## LAW 1 — Reference first, features later

The Bitcoin lane is **not** a feature. It is the **reference implementation** for every future cyber job.

**Before adding functionality**, document in the task or PR notes:

```text
What part of this system will Hacker reuse?
What part will Banker reuse?
What part will Government reuse?
```

| Answer | Action |
|--------|--------|
| Reusable **code** (shared SCSS, entity pattern, RPC shape) | Proceed |
| Reusable **reference standard** (scale, collider, proof workflow, visual language) | Proceed — required for Phase A mesh work |
| **Neither** — one-off with no clone path | **Stop** — reconsider or park |

Prefer extending shared surfaces (`LpOpsCrtTerminal.scss`, `LpHashdPanel` patterns, hub entity base behaviors) over one-off Bitcoin-only code.

**Phase exception:** UI-only preview (`lp_bitcoin_preview_hub` / `lp_bitcoin_preview_terminal`) is allowed during Phase A for Razor compile — it does **not** start Phase B world/gameplay work.

---

## LAW 2 — Shared visual language

By the end of Bitcoin, the player should **instantly** recognize:

| Type | Visual identity | Bitcoin entity |
|------|-----------------|----------------|
| **Hub** | Physical machine + **modern admin dashboard** on USE | `bitcoin-miner` → `LpHashdPanel` |
| **Terminal** | Information / control — typed commands | `bitcoin-terminal` → `LpBitcoinTerminalPanel` |
| **Rack** | Scaling / expansion — production unit; USE opens CRT focused on rack | `gpu-rack` / `advanced-gpu-rack` |
| **Power / error** | Universal warning language | Off = dark; blocked = explicit message |
| **Active / success** | Universal success language | Powered + mining = unmistakable live read |

Every later cyber lane **inherits** these rules. A player should see an object and know:

> **"That's a LIFEPUNCH machine."**

---

## LAW 3 — Pattern library (solve once)

Every solved problem becomes a **reusable pattern**. Do not solve the same UX problem twice.

| Pattern | Bitcoin canonical surface | Clone target |
|---------|---------------------------|--------------|
| Terminal screen layout | `LpBitcoinTerminalPanel` + `lp-ops-crt--gray` | Hacker green, Gov cyan, … |
| Hub admin dashboard | `LpHashdPanel` (amber ops) | Server rack menus, vault hub |
| Status panel / metrics | Overview tab, status chips | Per-lane telemetry |
| Upgrade panel | Hub Settings / Racks tabs | Hardware tiers |
| Notification style | Log lines, boot sequence | CRT scrollback |
| Progress feedback | Mining ticks, payout display | Job-specific yields |
| Error messaging | `log-line.err`, hub-off block | Consistent wording |
| Power indicators | `IsPowered`, emissive/audio | All hubs |

New patterns → document in `BITCOIN_REFERENCE_IMPLEMENTATION.md` when signed off.

---

## LAW 4 — Readability over realism

Cyber systems fail when they become **visual clutter**.

**30-foot test** — use **~15–20 m in-game** on flatgrass (s&box units; citizen ~72u tall). Stand back until the hub fills roughly ⅓ of the view:

```text
Can you tell:
  - What it is?
  - Whether it works?
  - Whether it needs attention?
```

If **no** → simplify materials, emissive, audio, or UI density. Realism that hides state is wrong.

---

## LAW 5 — Flatgrass is the truth

Editor screenshots are **not** proof. Only **gameplay** proof matters.

**Required before any sign-off:**

```text
Citizen scale comparison
Day test
Night test (may need time-of-day / lighting setup on flatgrass)
Movement test (walk around, distance read)
Interaction test (USE hub, terminal, rack)
```

**Two proof tiers (DXRP lane):**

| Tier | When | Acquire / spawn | Exit test |
|------|------|-----------------|-----------|
| **Dev sign-off** | Now (Phases A–C polish) | `lp_map_flatgrass` → `lp_bitcoin_spawn_kit` | Full USE loop without ConCmd job verbs |
| **Ship sign-off** | After portal row + publish | Player acquires from DXRP market | Law 10 loop — no dev spawn ConCmds |

Anything that fails in flatgrass host play is **unfinished** — status = NOT DONE. Editor-only or prefab-tab preview does not count.

Play law: `game.scene` → Host Play (2–5 min cold) → `lp_map_flatgrass` → spawn kit. See `BITCOINMINING_PLAYTEST.md`.

---

## LAW 6 — Every state must be obvious

**Implementation canon:** `LIFEPUNCH_DIGITAL_MACHINE_STANDARD.md` (OFF → BOOTING → RUNNING → OVERCLOCK / BROKEN / HACKED; lights, fans, sound follow state — not texture-only).

For **Hub**, **Terminal**, and **Rack**, these states must be readable **without opening a menu**:

```text
OFF
BOOTING
ONLINE
WORKING
WARNING
ERROR
UPGRADING
```

| Entity | OFF | BOOTING | ONLINE | WORKING | WARNING | ERROR | UPGRADING |
|--------|-----|---------|--------|---------|---------|-------|-----------|
| **Hub** | Dark, no fan | Power-on sequence / PIN | Powered, fans idle | Linked racks mining | Hub off, racks blocked | Missing link / auth fail | Upgrade purchase flow |
| **Terminal** | Hub off → blocked | Boot splash + rig0 lines | Prompt ready | Commands executing | Hub offline warning | Command rejected | N/A |
| **Rack** | Idle mesh | Link pending | Linked, not mining | `IsMining` emissive/audio | Unlinked / out of range | Hub off | Hardware tier change |

A **spectator** should know the state at a glance.

**Lane reality:** v2 today exposes `IsPowered` / `IsMining` + terminal boot UI only. Full world-readable OFF/BOOTING/WARNING/ERROR/UPGRADING is a **deliverable** (checklist H4, H9, R4) — not a blocker to *start* Phase A, but required before Phase C sign-off.

---

## LAW 7 — Preserve the brand matrix

Before sign-off, verify against `TERMINAL_BRAND_MATRIX.md`:

```text
Color language      (Bitcoin = amber #f0a500 — not hacker green / gov cyan)
Naming language     (hashd, rig0>, LIFEPUNCH™ source)
Terminal naming     (program + prompt per matrix)
Feedback language   (consistent power/mining/error strings)
Status wording      (no ad-hoc labels per session)
```

**No ad-hoc wording. No random UI styles.** Fork SCSS theme modifiers (`lp-ops-crt--*`), do not invent parallel layouts. Verify against **v2 code** (`LpHashdPanel`, `LpBitcoinTerminalPanel`) — not v1 `HashdTerminal` names.

---

## LAW 8 — Capture the Bitcoin bible

When Bitcoin Phases A–C are **complete**, populate:

```text
BITCOIN_REFERENCE_IMPLEMENTATION.md
```

With screenshots, dimensions, visual rules, interaction rules, upgrade rules, UX standards, and naming standards.

**Future jobs copy this document before they copy code.**

Until sign-off: the file exists as a **stub** — do not treat empty sections as canon.

---

## LAW 9 — Protect against "one more thing"

When a contributor says:

> "While we're here…"

**Stop.** That phrase destroys schedules.

Auto-park anything that begins with:

```text
While we're here...
Since we're already...
It would be cool if...
```

→ `BACKLOG_PARKING_LOT.md` — **not** the current milestone.

---

## LAW 10 — Actual exit condition

**Ship sign-off** — when a **brand-new player** can:

```text
Acquire hub (DXRP market — not dev ConCmd)
  → Place hub
  → Open Terminal
  → Understand what it does
  → Connect Rack
  → Observe production
  → Understand success / failure
  → Feel progression
```

**Without** Discord help, admin help, or developer explanation.

**Dev sign-off (current milestone):** same loop using `lp_bitcoin_spawn_kit` on flatgrass after host play — proves patterns before market row exists.

Maps to `ACTIVE_WORKSTREAM.md` §8 and tracker gate **BITCOIN SHIP GATE**.

---

## DXRP lane — known gaps (documented, not law violations)

These are **inconsistent with full ChatGPT exit fantasy** but **expected on this lane today**. Do not pretend they are done.

| Gap | Status | Notes |
|-----|--------|-------|
| Market acquire / place | **Portal Rev 1 live** — addon `019ec9a4-d867-7668-b452-904f97493c7e` (`lifepunchbitcoin`); content snapshot published (4 entities); **not gamemode-pinned**; **no code/assets upload yet** | Rev 1 = content-row placeholder only. Ship-tier Rev 2+ needs `_c` + `prepare-publish.ps1` upload + gamemode pin before market acquire |
| Gov/LE blocked from hashd | **Doc only** | `TERMINAL_BRAND_MATRIX.md`; not enforced in `LpBitcoinHubEntity` yet |
| Full Law 6 world states | **Partial** | Boot splash = UI; emissive/audio = H4/R4 checklist |
| PIN graphical gate | **H9 open** | `AccessPinIsSet` in code; full numpad flow TBD |
| `lp_authorize` | **Optional for polish** | Wallet sell proof may need portal token |
| Dedicated server `_c` | **Required for ship** | Compile + `Pull-DxrpCompiledAssetsToRepo.ps1` |
| Dev ConCmds | **Strip before publish** | `LpBitcoinDevSpawn` is playtest-only |
| Per-rack BTC balance | **v2 code** | `LpBitcoinRackEntity.BitcoinAmount` — bible must match code, not v1 hub-wallet doc |

**s&box ceilings agents must respect:** no SCSS gradients · `HashCode.Combine` ≤ 8 args · host-authoritative mining RPCs · `RestrictCloudOrg = facepunch` (self-contained assets).

---

## LAW 11 — Cyber economy rails

**Canonical detail:** `CYBER_ECONOMY_RAILS.md`

Before any economy or payout code in a cyber lane, classify the action:

| Class | Rule |
|-------|------|
| **BTC** (hub wallet, portal stack, P2P hub transfer → cashout) | Always **bank cashout** — `PayHost(..., inBank: true)` |
| **Hacker player attack** (puzzle, scan steal) | **Wallet cash only** — `HackerJob.BankUntouchable`; never bank |
| **Advanced hacker / gov police task reward** | **Bank cashout** for validated task completion — not a wallet steal |

Do not route hub BTC cashout to on-hand wallet. Do not let standard hacker paths touch `BankBalance`. Future Banker/Government lanes inherit these three rails.

---

## Agent session checklist (laws + gate)

1. `ACTIVE_WORKSTREAM.md` — single lane, current phase.
2. **This file** — Laws 1–11.
3. `OWNER_PROGRESS_TRACKER.txt` — one checklist ID.
4. Law 1 reuse question — answer before coding.
5. Law 9 — reject scope creep phrases.
6. Law 5 — flatgrass proof before "done."

**Last updated:** 2026-06-22 (Law 11 economy rails + DXRP lane gaps)
