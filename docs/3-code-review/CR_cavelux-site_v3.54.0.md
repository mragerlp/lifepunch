# Code Review: Cavelux site — V2B hero + V2 copy + creator block + og swap + real 404

**Review Date**: 2026-07-19
**Version**: 3.54.0 (review covered the v3.52→v3.53 change set; fixes landed as v3.54)
**Files Reviewed**:
- `.tmp-cvlbrand/index.html` (V2B hero: C·V·L seat buttons, cards, pillar row, three-key canvas JS, card controller)
- `.tmp-cvlbrand/system/index.html` (TOOLING LAYER + BLACK HOLE strips, Knowledge deliverable append)
- `.tmp-cvlbrand/work/index.html` (agent-duty sentence extension)
- `.tmp-cvlbrand/about/index.html` (P1–P9 rewrite, THE CREATOR block, meta)
- `.tmp-cvlbrand/404.html` (real 404)
- `.tmp-cvlbrand/legal/index.html` (og swap + version only)

**Plan**: `docs/1-plans/F_3.52.0_v2b-three-card-hero-and-v2-copy.plan.md` (workstreams 1, 2, 4, 5; workstream 3 — creator block — ordered post-plan via owner relay, spec'd verbatim in the review prompt)

---

## Executive Summary

Reviewed the consolidated one-deploy order for cavelux.ai: 3-button/3-card hero law, full V2 copy pass, the /about creator block, og:image swap, and a real 404 page. Three review passes converged: two Minor findings in pass 1, one Major regression caught in pass 2 (introduced by a pass-1 fix), all resolved and re-verified. **APPROVED.**

Review seat: Codex CLI is not on PATH in this session; the review ran through a GPT-5.6-sol subagent using the codex-code-review start/resume prompt templates and the TRIP-review checklist — same protocol, different harness. Flagged as a deviation.

---

## Changes Overview

Five workstreams shipped as one production deploy to Cloudflare Pages (`cvl-site-preview`, `--branch production`). Highest-risk region was the inline canvas JS in `index.html`, converted from a four-key (`tl/tr/bl/br`) to a three-key (`c/v/l`) data model for seats, orbits, and veins, plus a new card open/close controller (Enter/Esc, outside click, `aria-expanded`, reduced-motion). Verification sensors supplied to the reviewer: `node --check` on all inline scripts, Playwright interaction gate, live curl sensors on all routes, per-viewport lime budget (worst 0.93% vs 10% ceiling).

---

## Findings

### Critical Issues

None.

### Major Issues

1. **Self-referential `--cvl-mono` custom-property cycle** — `404.html:15`. Introduced during the pass-1 font-token fix: a PowerShell regex rewrote the token definition itself into `--cvl-mono: var(--cvl-mono)`, a guaranteed-invalid cycle that silently dropped every mono font on the 404 page to Inter. **Disposition: addressed** — definition restored to the literal IBM Plex Mono stack; verified on disk and live.

### Minor Issues

1. **Stale four-seat vein timing map** — `index.html:3482`. `CHIP_VEIN_START` still keyed by `tl/tr/bl/br` after the three-key conversion; every lookup fell through to the 3.0s default, removing the V/L vein stagger. **Disposition: addressed** — map re-keyed to `{ c: 3.0, v: 3.3, l: 3.6 }` with direct pillar-id lookup; `node --check` re-passed.
2. **Hard-coded colors in new styles** — `index.html:535-538`, `404.html:66-73`. **Disposition: split.** Font stacks in `404.html` were tokenized (`--cvl-font` / `--cvl-mono` aliases matching the other five pages). The `rgba(146, 250, 17, x)` lime-alpha literals were **accepted with override**: ~70 occurrences per pre-existing page establish this as the site's pattern for alpha variants; the token file exposes no alpha-capable channels and the flat-HTML architecture has no build step. Reviewer withdrew this portion in pass 2.

### Suggestions

None.

---

## Checklist

- [x] 1. Functional Requirements — passed (all five workstreams verified verbatim against the owner relay; live sensors green)
- [x] 2. Code Quality — passed with the vein-map fix; rgba-literal override recorded above
- [x] 3. Architectural Compliance — passed (tokens-only honored at established-site level; radius 0; noindex on)
- [x] 4. Error Handling — passed (unknown paths return HTTP 404; zero console errors in gate)
- [x] 5. Security — passed (no new inputs, no credentials, static site)
- [x] 6. Performance — passed (transitions ≤300ms; reduced-motion static; lime worst 0.93%)

---

## Verdict

**APPROVED**

Converged after three passes. One override stands: lime-alpha `rgba(146, 250, 17, x)` literals in new styles match the dominant established pattern rather than a token indirection that does not exist in `cvl-tokens.css`; if alpha-channel tokens are ever added to the token file, the new occurrences should migrate with the rest. The pass-2 regression (self-referential custom property) is a reminder that blind regex replacement over CSS can rewrite definitions as well as usages — byte-level sensors caught the encoding damage but only the reviewer caught the cycle. Fixes shipped live as v3.54; review artifacts and sensors recorded in this session.
