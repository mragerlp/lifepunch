# LifePunch "Hacker Job" — Design Spec (DRAFT)

> **Status: Phase 1 GREENLIT (terminal shell + puzzle stubs).** Economy / wallet transfer remains
> **Tier-1 Opus** — not implemented until Phase 2 sign-off. Manifest: `addons.json` → **`hackerjob`**
> (`dxrpAddonId 019e448c-4958-77d1-84b7-c7ec3f1bc328`). Build checklist: `hackerjob/docs/HACKER_TERMINAL_BUILD.md`.
> **Roadmap after Hacker Job:** Government Database (`GOVERNMENT_DATABASE_SPEC.md`).
>
> Per `dxrp-addon-foundation`: propose feature set + architecture + permission mapping for
> **owner sign-off before building**. This addon **touches the economy** (player money), so it is
> **Tier-1 (Opus) / high-stakes** work — server-authoritative, validated, never driven by a local
> model's output.

---

## 1. Concept (owner's vision, verbatim intent)

The **"Hacker"** is a **DXRP job** that LifePunch creates. Core loop:

1. **Entities — two hacker terminal tiers** (`TERMINAL_BRAND_MATRIX.md`):
   - **Starter kit** — `server-rack` + **Hacker Terminal** (Cornerman green): **low price**, **less secure**, wallet `scan` / `hack` only. This is what the Hacker job starts with.
   - **Purchased upgrade** — `advanced-server-rack` + **Advanced Hacking Terminal** (VENGEANCE red): **much more expensive**, higher-end hardware, **more complex** commands, **higher rewards** — targets include player **bitcoin miners**, **bank**, and **government datacenter** / city funds (`govdb` / `infil`).
   Retro CRT models (owner will source/make).
2. **Interact → log in** — USE the Hacker / Advanced Hacker Terminal to boot the attached program UI
   (Cornerman green / Vengeance red). See `hackerjob/docs/TERMINAL_SESSION_DOCTRINE.md`.
3. **Boot `cornerman.exe`** — the ops console loads **`cornerman.exe`** —
   themed *after* Cornerman (our local AI box) but **explicitly NOT the real Cornerman**: it's an
   in-world fictional program / flavor nod, not a reference to the actual workstation.
4. **Scan** — once `cornerman.exe` finishes loading, the terminal lets the player **"scan" for
   SteamIDs**, surfacing **real, currently in-game players**.
5. **Hack the wallet** — the player then **"hacks"/steals money from a target's WALLET (NOT their
   bank)** by completing a **small, smart coding puzzle within a time limit**.

> Wallet ≠ bank is a hard rule: only on-hand/wallet cash is at risk; banked money is untouchable.

---

## 2. First-pass architecture sketch (to refine at sign-off)

Aligned with our patterns (prefab + component composition; server-authoritative economy; engine
systems as designed — see `REUSABLE_ADDON_FRAMEWORK.md`, `lifepunch-quality-bar`).

- **Entity:** `Hacker Terminal` prefab (`simple-entity`) — world model = the retro CRT/monitor,
  with a `Use`/interaction component that opens the screen UI for the interacting player.
- **Screen UI:** a **Razor `WorldPanel`** (`.razor` + `.scss`) rendered on the monitor face —
  boot animation → `cornerman.exe` load → scan list → puzzle. Reuse the **Cornerman terminal
  aesthetic** (green-on-black ops theme) for brand cohesion. *(All `.cs`/`.razor`/`.scss` files
  get the PROPRIETARY header per `dxrp-addon-foundation`.)*
- **Scan:** server builds the target list from live players (filter rules TBD — e.g. exclude self,
  maybe range/connection-state gating, maybe exclude other hackers / staff). Client only displays
  what the server authorizes.
- **Puzzle:** client-side mini-game (the "coding puzzle"), but the **outcome is server-validated** —
  the client never asserts success or moves money. Time-boxed; expiry = fail.
- **Money transfer:** **server-authoritative** via DXRP's money/economy API. Debit **target wallet**
  (clamped to available wallet cash), credit hacker. Never trust the client for amounts.
- **Job integration:** "Hacker" registered as a DXRP **job**; only that job can use the terminal's
  hack flow (terminal may be world-placed/mappable).

## 3. Anti-abuse / balance (must-haves, detail at sign-off)

- Server validates job, distance/LOS to terminal, target validity, puzzle result, and timing.
- **Wallet-only**, clamped to the target's current on-hand cash (no negative balances / overdraft).
- Per-hacker and/or per-target **cooldowns**; cap stolen amount/rate.
- **Risk/counterplay:** failure penalty and/or alert hook (e.g. police/target notification) — TBD.
- Audit every transfer (ties into `AUDIT_LOG_REFERENCE.md`) for moderation/abuse review.

## 4. Naming / IP notes

- Lead with **LIFEPUNCH** in any product/package name ("LIFEPUNCH Hacker Job for DXRP"). DXRP is a
  third-party platform — reference nominatively only (`lifepunch-trademark-ip`).
- **`cornerman.exe`** is in-game fiction; keep it clearly a flavor program, not a claim about /
  reference to the real local workstation.
- Original code + self-authored assets only → this is shippable **LifePunch IP**. The CRT model must
  be self-made or owned/licensed (no third-party-modeled assets in shipped content).

## 5. Open questions for the in-depth pass

- Scan scope: server-wide vs. range-limited? Who's excluded (staff, other hackers, downed players)?
- Puzzle: what *is* the "coding puzzle" (format, difficulty scaling, generation)? Skill-gated payout?
- Amounts: flat vs. % of wallet vs. scaling with puzzle difficulty/time remaining; daily caps.
- Counterplay: does the target get notified / a chance to react? Police integration? Trace risk?
- Placement: terminals map-placed by server owners, or spawnable by the Hacker job? How many?
- DXRP job/economy API surface: confirm the exact money + job hooks against `dxura/dxrp @develop`.

## 6. Phased rollout

| Phase | Owner | Deliverable |
|-------|-------|-------------|
| **1 — Terminal shell** | Green (Cornerman) | Standard + Advanced tiers, scan/govdb stubs, puzzles, `lp_cornerman_ui` / `lp_vengeance_ui` — **no money moved** |
| **2 — Economy** | Red (Opus) | Job gate, live scan, server-validated puzzles, wallet debit/credit, cooldowns, audit |
| **3 — Assets** | Red | CRT model, prefab, sounds, optional WorldPanel on monitor |
| **4 — Polish** | Owner + Opus | Tabbed UI (optional), counterplay, balance tuning |
| **Later** | TBD | **Government / FBI protagonist cyber (Phase F)** — finish Hacker Job first. `government-server-rack` hub + lifepunchnet `police-terminal` vs red-tier breaches. See `GOVERNMENT_DATABASE_SPEC.md` |

Cornerman drafts Phase 1 UI + puzzle framework. **Opus owns Phase 2 economy** — never trust client puzzle success or amounts.

## 7. Status / next step

Phase 1 code on Green. **Editor playtest:** spawn bots (`lifepunch_spawn_testbot`) then `scan` — live roster, not hardcoded stub ids (`hackerjob/docs/HACKER_JOB_PLAYTEST.md`). Red: Opus review → CRT prefab → Phase 2 economy.
