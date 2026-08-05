# LifePunch Wallet Work Handoff

**Date:** 2026-08-04  
**Product:** `lifepunch.wallet` inside `lifepunch.bitcoin`  
**Preview status:** complete, verified, and browser-tested  
**Production status:** intentionally stopped at the host-authority gate  

## What is ready

- `preview/` is a self-contained, interactive **LOCAL PREVIEW** with Overview,
  Send, review, receipt, and Activity states.
- `preview/LpWalletPreview.razor` and its SCSS are presentation references for
  the eventual s&box UI; they are not asserted to compile in the editor.
- `planning/` contains the approved design, production execution plan, and
  static-preview plan.
- `integration-evidence/` records why production money-flow work is stopped.
- `production-source-worktree` links to the isolated Git worktree containing
  the reviewed Task 1 authority-intake commit; the 5.7 GB tree is not duplicated.

## Verified evidence

- Static preview verifier: **51/51 passed**.
- Screenshot: valid PNG, **1440 x 900**.
- Browser checks: all three routes; malformed, sub-satoshi, zero, and
  over-balance amount rejection; exact satoshi review; inert modal boundary;
  Escape focus restoration; local receipt; immutable Overview balance;
  Activity filtering; copy and close feedback.
- Browser console: no warnings or errors during the checked flow.

## Production boundary

The preview does not register `/wallet`, persist balances, call a host, or move
BTC. Production implementation remains gated on an approved, host-authoritative
atomic BTC ledger and editor/two-client proof, as detailed in
`integration-evidence/HOST_RAIL_INTAKE.md`.
