# LP PLAYER HUB — SLICE LADDER STATUS (reclassified 2026-07-14)

**STATUS NOTE, not a plan.** The plan is
[`2026-07-14-lp-player-hub-implementation-plan.md`](2026-07-14-lp-player-hub-implementation-plan.md) and
its design sibling. **This note records which rungs are climbable and which are gated, and WHY.**

**Rulings:** `comms\fable\0073` → `lifepunch/docs/cvl/PLAYERHUB_GATES_RULING_2026-07-14.md`.
**Seam evidence:** `lifepunch/docs/handoff/GREEN_0017_PLAYERHUB_3LANE_SCAN_2026-07-14.md` (tracked copy of
Green OUTBOX `0017_GREEN_PLAYERHUB-3LANE-SCAN_2026-07-14.md`).
**Workstream:** **OPENED** — `lifepunchaddons/docs/ACTIVE_WORKSTREAM.md` (two lanes now).

---

## THE LADDER

| Slices | State | Why |
|---|---|---|
| **1 – 5** | ## **UNBLOCKED** | Fixture-backed, read-only. Seams **pre-verified** by Green `0017`. **Build them.** |
| **6** | **RECLASSIFIED — not blocked, not trivial** | See below. |
| **7 – 8** | ## **GATED** | **Progression contracts do not exist.** See below. |

## SLICE 6 — it was never a missing rail. It is a **missing guarantee.**

> **The `$LP` inventory rail EXISTS.** `lifepunchdxrp\game\Code\Api\ServerApiClient.Inventory.cs` —
> **addon-callable** (sensor: Green `0017`).
>
> **What is absent is ATOMICITY / IDEMPOTENCY.**

**This is a DESIGN slice under existing economy law, not a plumbing slice.** It gets **its own slice and
its own ruling, AFTER 1–5.** It must satisfy `lifepunch-economy`:

- **P1 — debit before await.** And **the right restore**: a **snapshot** restore (`= walletBefore`) is valid
  **only in an await-free segment**; anything straddling an await must be **additive** (`+= amount`).
  **A snapshot restore across an await IS the bug** (`red\0034` §2).
- **P4 — authority.** Host-resolved `Rpc.CallerId`. **Never a client-supplied SteamId or price.**
- **P10 — idempotency.** `requestId` / `operationId`; **a replay returns the prior result, it does not mint
  again.** *This is the actual content of Slice 6.*

> ⚠ **The rail existing is exactly what makes this dangerous.** A slice that "just calls the API" **looks
> finished and ships a double-spend.** *Do not let the presence of a rail be mistaken for the presence of a
> guarantee.*

## SLICES 7 – 8 — GATED on contracts that **do not exist**

| Finding (Green `0017`) | Consequence |
|---|---|
| **LIFETIME STATS LEDGER: NONEXISTENT.** **Kills and deaths DIE ON DISCONNECT** — nothing persists them anywhere. | A "lifetime stats" tab has **no source of truth to read.** Building one means **inventing a ledger**, which is a **ruling**, not a slice. |
| **Skill-point spend = TENANT #2 of `LifePunchUpgradeTracks`** | **Reuse the existing system. Do not build a second one.** *(And do not let tenant #2 quietly become a fork of tenant #1.)* |

> ## **ABSENCE OF A CONTRACT IS A BLOCKER, NOT PERMISSION TO INVENT LOCAL SUBSTITUTES.**
> (`.claude/skills/lifepunch-plan-shape`)
>
> **Inventing a local kill/death counter or a fake catalog to "unblock" 7–8 is a skill-miss AND an economy
> defect.** It manufactures the appearance of progress and **hides a missing ruling.**
> **A gate blocks. It is not a to-do.**

## SETTLED (no longer gates)

- **Package identity — CONFIRMED.** `playerhub` / `lifepunchplayerhub` / `lifepunch.playerhub` /
  `lifepunchhub` / `lifepunchaddons/Code/Addons/lifepunch/playerhub/`.
  **⚠ `code-only` is conditional on the Inter font proof** — if Inter must ship as an **asset**, the
  manifest kind gets **its own ruling** (`kepler\0001` Gate 1). **Do not assume it survives.**
- **UI-STANDARD conflict (Gate 3) — MOOT.** Commit **`4aa46d00`** reconciled `LIFEPUNCH_UI_STANDARD.md` to
  blue / 12px / 6px. **Doc and code agree.**
- **`$LP` token — blue `#017AEF` + white amount, TEMPORARY**, pending the currency-identity ruling.
  Carried as **PENDING-RATIFICATION** in `lifepunch-design-tokens`. **Label it temporary in UI copy.**

## WHO BUILDS

## **Slice 1 DRIVE: RED — build AND editor proof, one seat.**

**REASSIGNED 2026-07-14, Bloodwave.** Canon:
[`lifepunch/docs/cvl/PLAYERHUB_SLICE1_DRIVE_REASSIGNMENT_2026-07-14.md`](../../cvl/PLAYERHUB_SLICE1_DRIVE_REASSIGNMENT_2026-07-14.md).

> **This line previously read "the KEPLER orchestrator builds."** That clause of `fable\0073` /
> `PLAYERHUB_GATES_RULING` is **SUPERSEDED** by the companion record above. *The ruled file itself is
> **not** edited — it is `CLASS: RULED`. This is a status note, so it is corrected.*

**Kepler / OpenCode is a NON-BLOCKING BACKGROUND ERRAND** — it **gates nothing**: the `fable\0074` config
paste, the first-session **skill-ROOTS report** (the `.agents/skills` consumer test held since `red\0033`),
and the `opencode models` provider id for `codex-review`.

> ## **RED RUNS THE EDITOR PROOF GATE. EDITOR TRUTH STAYS RED'S REGARDLESS OF WHO BUILDS.**
> That sentence is now simply **unremarkable** — the builder and the prover are the same seat. **Splitting
> build from proof buys nothing once the prover can build, and it costs a handoff.** *A handoff is where
> state goes stale.*

**MCP STACK: ALL THREE SURFACES LIVE** (re-verified `red\0037`, 2026-07-14 12:15Z — native `7269` HTTP 200
+ `editor_status`; chomnr `9090` `running:true`; Bridge **`bridgeVersion:"2.1.0"` NON-NULL**, 171 ms
heartbeat; corroborated outside the endpoints by `tasklist` PID 25948 and `netstat` listeners).
**They were DOWN at the boot before it** (`red\0036`) — *so the recovery is a sensor reading, never an
assumption, and it is re-taken every boot.*

> **`versionsAligned: true` is a FALSE PASS on `null == null`** (`red\0032`, **still unfixed — it fired
> falsely twice on 2026-07-14**). **Assert the non-null `bridgeVersion`. Never read the boolean.**

## ⚠ BEFORE BUILDING FROM THE SEAM TABLE

Green `0017` is **42/43 HOLD @ `08ad8544`** and **names three of its own cite corrections**: **row 23 path**
(`LpBitcoinHubEntity.cs` lives under `lpbitcoin\bitcoinhub\code\components\`, **not** `bitcoinmining\` — an
implementer following it literally **opens a nonexistent file**), row 29 description, and **rows 5/6
off-by-one ranges**.

> ## **L3 CITES REQUIRE MACHINE VERIFICATION. EVERY TIME.**
> **Re-grep every seam against the live tree before you build on it.** Two L3 seats filed bad cites on
> 2026-07-14, and one would have **re-created a fixed money bug** (`red\0034`). **Green flagged its own
> three. Verify the other forty anyway.**
