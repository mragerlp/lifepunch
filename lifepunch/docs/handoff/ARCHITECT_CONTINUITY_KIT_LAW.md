# LIFEPUNCH™ Design Architect — continuity kit law

> **Status:** Owner law — ChatGPT Project onboarding + refresh discipline  
> **Canonical repo:** https://github.com/mragerlp/lifepunch (always wins over uploaded ZIPs)  
> **Builder:** `lifepunch/scripts/Build-ArchitectChatGptOnboardZip.ps1 -Build`

---

## Baseline

Treat commit **`782ef35`** as the current continuity-kit baseline until superseded.

**GitHub remains authoritative.** The Desktop / Project ZIP bundle is a **snapshot only** — not law, not a second source of truth.

Design Architect may apply **package-only** normalization (metadata stamps, flat filenames, checksums) when reconciling a Red-built export. Rebuilt archive hashes may differ from VENGEANCE reference checksums; content at the same source commit is what matters.

---

## Future updates (what Integration Architect sends Design Architect)

Send:

1. **New source commit hash** (short SHA on `main`)
2. **Changed files list** (paths + one-line why)

| Change size | Action |
|-------------|--------|
| **Small / localized** | **Delta refresh** — replace only touched files in Project knowledge |
| **Laws, onboarding, `ARCHITECT_CURRENT_STATE.md`, `DECISIONS/*`, or `ACTIVE_WORKSTREAM.md`** | **Full continuity kit rebuild** — regenerate ZIPs, integrity pass, new checksums |

When in doubt, rebuild the kit.

---

## CVL role split

| Role | Action |
|------|--------|
| **Red — Integration Architect (VENGEANCE)** | Maintain **canonical commits** on GitHub; run zip builder after doc commits when kit rebuild is triggered |
| **Green — Distillation Architect (Cornerman)** | **Sync from Red only** (`git pull --rebase` on GitHub clone); never ship canon independently |
| **Design Architect (ChatGPT)** | **Reconcile** Red updates; regenerate / normalize packages when needed; integrity report + checksums |

**Blue (Operations Architect / lifepunchnet):** GitLab `lifepunch-rdp-server` lane only — doc mirror arrives via **owner lane export**, not direct GitHub pull.

---

## Upload kit shape (reference)

Flat filenames · 38 content files · 2 chunks (19 + chunk readme each) · README zip · see `ARCHITECT_HANDOFF_README.md`.

**Last updated:** 2026-06-25 · baseline `782ef35`
