# Automation hardening — hooks, tailnet, native migration (instrument)

**Status:** INSTRUMENT — rulings recorded, **builds unexecuted.** Editable until each
item's verdict lands; results freeze per the hybrid ruling as they land.
**Ruled by:** Bloodwave (via Fable), 2026-07-10.
**Companions:** `RECON_ATTACK_SURFACE_2026-07-10.md` (S1–S8) ·
`STOPGO_SEAT_LOCAL_PERMISSIONS_2026-07-10.md` · `GATE_ODYSSEUS_P1_VERDICT_2026-07-10.md`

**Nothing here is armed mid-arc.** Every item builds **post-chair**, behind the merge gate,
and none of it merges anything or decides anything. `.github/workflows/gate-assist.yml` is
the advisory robot this record's siblings hand work to: **it paints a check red and stops.**

---

## H1 — HOOKS (ruled; build POST-CHAIR)

**The rituals that are mechanical should be mechanical.** Three pre-tool-use hooks, encoding
what a human has been doing by hand all session:

1. **Pre-commit secret gate** — the canonical `§6` pattern with its length anchor, plus the
   placeholder exclusions. *An alarm that cries wolf on a template is an alarm people learn to
   ignore.*
2. **Attribution grep** — anchored to the **trailer's line start**, never to a bare word.
   `claude` matches the filename `CLAUDE.md`; `^Co-authored-by:` matches a trailer. That
   distinction is a worked example in `PROOF_ENVIRONMENT_DOCTRINE.md` and it has cost this
   repo real time more than once.
3. **Docs-pass `.cs` guard** — a commit whose subject opens `docs(` or `chore(` and whose diff
   carries `.cs`/`.razor`/`.scss`/`.ps1` gets flagged. **Advisory.** A docs pass may
   legitimately touch code; the point is that a human sees it said so.

### Configuration — tracked or seat-local?

**Proposed in the build pass, per the settings law.** Hook *definitions* are discipline and
belong in the merge gate, like skills. Hook *approvals* — whatever a seat has consented to run
— are decisions, and **decisions do not replicate**
(`STOPGO_SEAT_LOCAL_PERMISSIONS_2026-07-10.md`). If a hook's config cannot be split cleanly
along that line, it stays seat-local and the split is proposed as its own ruling.

### CERTIFICATION — required before any hook is trusted

> **A deliberate bad commit must be BLOCKED before any hook is believed.**

Plant a real violation — a live-looking token, an `AI-authored-by:` trailer, a `.cs` in a
`docs(` pass — and observe the hook refuse it. **A hook that has never fired is not a hook; it
is a decoration with a green light.** This is the Sensor Law applied to our own tooling: *when
no sensor reads the thing under test, build one — and then prove it reads.*

**Never armed mid-arc.** A hook installed between a gate's cases changes the assembly under
test, exactly as a mid-gate code fix does.

---

## H2 — TAILSCALE (S2 RULED: blessed)

**Ruled: Tailscale is the sanctioned remote-admin path.** It is not an unowned overlay; it has
a named purpose and an owner. S2's fail action — *uninstall* — does not apply.

**Rollout, POST-CHAIR, in this order:**

1. Install on **Red** and **Blue**.
2. **Then** `S1` closes Blue's admin surface off the WAN — RDP, SSH, WinRM, panel and runner
   ports become **tailnet-only**. Game ports stay open by design.
3. **Record at execution:** the device list and each key's expiry.

**Order is the whole ruling.** Closing the WAN admin ports before the tailnet path is up locks
the operator out of the box he is hardening. Install first, verify reachability over the
tailnet, *then* close. Blue's facts are asserted at **Blue's keyboard** — Red does not measure
another node.

Key expiry is a **standing item**, not a one-time note: an expired key is a locked door on the
day you need it open.

---

## H3 — NATIVE MIGRATION (re-confirmed, post-P2)

Re-confirmed for **after P2**, and the reason is measured, not stylistic:
`GATE_ODYSSEUS_P0_VERDICT_2026-07-10.md` records **Red on `2.1.187` (npm shim) and Green on
`2.1.206` (native exe)**, and it records the law that came with it —

> **Harness behavior does not cross the version gap.**

Every harness observation this repo holds is stamped with the build that produced it. A
migration collapses that gap and invalidates nothing that was measured; it simply means the
next observation is made on a different build and must say so.

**Post-P2**, because P2's corner-lane injection probe is a behavioural certification of the
seat, and changing the seat's runtime under an unfinished certification would void it.

---

## The advisory robot, for the record

`.github/workflows/gate-assist.yml` — added alongside this instrument.

- **Under the merge gate, never a merger.** `permissions: contents: read`, nothing else. It
  cannot comment, approve, or push. Findings surface as workflow annotations.
- **`pull_request`, never `pull_request_target`** — a read-only token, no secrets exposed to
  fork code.
- **Nothing from `github.event.*` is interpolated into a `run:` block.** A PR title or body is
  attacker-controlled text; inlining it is a script-injection sink. It travels through `env:`.
- **Patterns anchored to structure, never to a word**, and every secret pattern is written so
  it **cannot match its own source** — so the workflow is scanned by its own rules, with no
  self-exclusion and therefore no blind spot. *The comment that first explained that removal
  reintroduced the match; describe the literal, never write it.*
- **Certified before it shipped**, by the same standard H1 demands of hooks: 7/7 synthetic
  credential shapes fire; 0 false positives on placeholders, on prose, and on the documented
  `git grep` command that lives in canon.
- **Its first live pass is the NEXT PR.** It lands inside `#56` and cannot have run on it.
  Bloodwave's gate review covers that one, as always.

---

## Cross-references

- `RECON_ATTACK_SURFACE_2026-07-10.md` — S1 (Blue WAN listeners), S2 (this record's H2),
  S4 (DPAPI, repair #5), S7 (read-surface certifications).
- `STOPGO_SEAT_LOCAL_PERMISSIONS_2026-07-10.md` — why hook approvals may not travel.
- `GATE_ODYSSEUS_P1_VERDICT_2026-07-10.md` — the version-gap finding H3 cites, and the
  citation gate that is repair #4 of the worker pass.
- `PROOF_ENVIRONMENT_DOCTRINE.md` — the Sensor Law. *A hook that has never fired is not a
  hook.*
