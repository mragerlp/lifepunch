# DXRP #73 Party System — Review Distill + PR Checklist

**Route tag:** `GREEN READ-ONLY` (this distill task)  
**FOCUS:** DXRP upstream only — **not** LifePunch proprietary addons  
**Slice:** GitHub bounty #73 review / PR prep packet for Dimmer  
**Authoritative source:** `inbox/DXRP_73_BRANCH_MANIFEST.txt` + public fork `mragerlp/dxrp-public` @ `bounty/73-party-system` HEAD `9e424f2`

---

## Do

1. **Read-only distill** — no implementation, no git, no PR, no playtest claims.
2. Produce a **paste-ready VENGEANCE packet** for Red to open PR / hand to Dimmer.
3. Use report structure from `lifepunch/docs/handoff/LIFEPUNCH_AI_REPORT_TEMPLATE.md` but:
   - Header title: **DXRP AI REPORT** (not LIFEPUNCH™)
   - Project: `dxrp-public #73 Party System`
   - Branch: `bounty/73-party-system` @ `9e424f2`
4. **Route tags inside the packet** (label each subsection or file group):
   - `OPUS REQUIRED` — `PartySystem`, `PartyRoom`, `[Sync(FromHost)]`, host RPC authority, invite timers, FF bypass in `Player.Health`
   - `AUTO OK` — Razor/SCSS HUD, localization keys, PR description text, checklist bullets
   - `GREEN READ-ONLY` — this distill artifact only
5. Include **PR checklist** for reviewer (Dimmer): files touched, test steps, risks, open questions.
6. **FactionSystem:** read-only comparison only if needed — **do not** propose faction integration.
7. Compare UI patterns to **AdminTickets** / **DraggablePanel** (parity claim in branch) — file-level only, no viewport.

## Do NOT

- Implement or patch code on Green
- Commit, push, or open PR
- Claim playtest / flatgrass / drag verified
- Include LifePunch proprietary paths, headers, or branding
- Touch `FactionSystem` except read-only “separate by design” note
- Ship C# from Green

---

## Deliverables (write to Green outbox)

| File | Content |
|------|---------|
| `outbox/DXRP_73_REVIEW_CURSOR_BRIEF.md` | Paste-ready packet for Red Cursor chat — summary, route tags, review focus |
| `outbox/DXRP_73_PR_CHECKLIST.md` | Dimmer-facing checklist: scope, manual test steps, edge cases |
| `outbox/DXRP_73_OPEN_QUESTIONS.md` | Only items needing owner/reviewer decision |

Optional single rollup: `outbox/DXRP_73_REVIEW_DISTILL_2026-06-28.md` (full template report).

Every file footer:

```text
Cornerman's eyes are covered — distill from manifest/repo only; not playtest or viewport verified.
```

---

## Completion signal (exact format)

When done, write `outbox/DXRP_73_REVIEW_COMPLETE.txt`:

```text
OK cornerman dxrp-73-review-distill complete @<ISO-local-time>
head=9e424f2
outputs=<number>
eyes=covered
no-code
no-commit
```

---

## Warm model

`WarmDistill` before starting (Red should have dispatched).
