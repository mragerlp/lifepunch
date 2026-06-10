# LifePunch "Hacker Job" — Design Spec (DRAFT)

> **Status: DRAFT / concept captured — not yet greenlit for build.** This records the owner's
> vision so it lives in the source of truth instead of only in chat. The in-depth design pass
> (final feature set + architecture sign-off) happens later, "once we're all fully connected."
> Manifest entry already exists: `addons/config/addons.json` → ident **`hackerjob`**
> (kind `simple-entity`, `dxrpAddonId 019e448c-4958-77d1-84b7-c7ec3f1bc328`, `foundation-only`).
>
> Per `dxrp-addon-foundation`: propose feature set + architecture + permission mapping for
> **owner sign-off before building**. This addon **touches the economy** (player money), so it is
> **Tier-1 (Opus) / high-stakes** work — server-authoritative, validated, never driven by a local
> model's output.

---

## 1. Concept (owner's vision, verbatim intent)

The **"Hacker"** is a **DXRP job** that LifePunch creates. Core loop:

1. **Entity — "Hacker Terminal"** — a placeable `simple-entity` whose model is a **1990s–2000s
   computer screen** (owner will source/make the model). This is the world object the Hacker uses.
2. **Interact → on-screen UI** — when a player **interacts/uses** the terminal, a **Razor-coded
   worldscreen** lights up with the terminal visuals.
3. **Boot `cornerman.exe`** — the screen prompts/loads a program called **`cornerman.exe`** —
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

## 6. Status / next step

Concept captured. **No build until owner greenlights** the feature set + architecture here. When we
resume: lock §2–§3, answer §5, then scaffold the entity + Razor screen and wire the server-side
hack/transfer behind validation. Cornerman's role on this is **Tier-3 support** (drafting boilerplate,
summarizing the DXRP economy/job reference) — not driving the high-stakes economy logic.
