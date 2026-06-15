# Cyber reference laws — DXRP production gate (owner law)

**Status:** HARD GATE — applies to every `lifepunchbitcoin` session and every future cyber lane.  
**Parent gate:** `ACTIVE_WORKSTREAM.md`  
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
| At least one clear reuse path | Proceed |
| **"Nothing"** | **Stop** — reconsider building it |

Prefer extending shared surfaces (`LpOpsCrtTerminal.scss`, `LpHashdPanel` patterns, hub entity base behaviors) over one-off Bitcoin-only code.

---

## LAW 2 — Shared visual language

By the end of Bitcoin, the player should **instantly** recognize:

| Type | Visual identity | Bitcoin entity |
|------|-----------------|----------------|
| **Hub** | Physical machine — power, linking, upgrades | `bitcoin-miner` (Ophion) |
| **Terminal** | Information / control — typed commands | `bitcoin-terminal` (gray CRT) |
| **Rack** | Scaling / expansion — production unit | `gpu-rack` / `large-gpu-rack` |
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

**30-foot test** (stand back in flatgrass):

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
Night test
Movement test (walk around, 30-foot read)
Interaction test (USE hub, terminal, rack)
```

Anything that fails in flatgrass is **unfinished** — status = NOT DONE.

Play law: `game.scene` → Host Play → `lp_map_flatgrass` → spawn kit. See `BITCOINMINING_PLAYTEST.md`.

---

## LAW 6 — Every state must be obvious

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

**No ad-hoc wording. No random UI styles.** Fork SCSS theme modifiers (`lp-ops-crt--*`), do not invent parallel layouts.

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

Bitcoin is **done** when a **brand-new player** can:

```text
Place Hub
  → Open Terminal
  → Understand what it does
  → Connect Rack
  → Observe production
  → Understand success / failure
  → Feel progression
```

**Without** Discord help, admin help, or developer explanation.

That is the **real** sign-off test — stricter than "feels done" or "compiles clean."

Maps to `ACTIVE_WORKSTREAM.md` §8 and tracker gate **BITCOIN SHIP GATE**.

---

## Agent session checklist (laws + gate)

1. `ACTIVE_WORKSTREAM.md` — single lane, current phase.
2. **This file** — Laws 1–10.
3. `OWNER_PROGRESS_TRACKER.txt` — one checklist ID.
4. Law 1 reuse question — answer before coding.
5. Law 9 — reject scope creep phrases.
6. Law 5 — flatgrass proof before "done."

**Last updated:** 2026-06-15
