# CYBER VISUAL IDENTITY DOCTRINE — LIFEPUNCH

**Owner Directive:** Bloodwave (2026-06-25)  
**Status:** Binding planning canon for Bitcoin Step 1, Universal Upgrades, Terminal brand work, and all future lane planning.  
**Red Addendum integrated:** Yes (see below).  
**No code** is authorized from this document alone.

---

## Owner Asset Intake Locations (reference only)

```
C:\Users\jared\OneDrive\Desktop\hackerassets
C:\Users\jared\OneDrive\Desktop\hackerassets\advancedhackerassets
C:\Users\jared\OneDrive\Desktop\hackerassets\governmentandpolicehackerassets
```

These are **owner-controlled intake / reference sources**. They are not runtime paths and must not be referenced directly from shipping code.

---

## Locked Visual Identities

| Lane                        | Machine Identity     | Accent       | Program              |
|-----------------------------|----------------------|--------------|----------------------|
| Hacker                      | Cornerman            | Green        | `cornerman.exe`      |
| Advanced Hacker             | VENGEANCE            | Red          | `vengeance.exe`      |
| Government / Police Hacker  | lifepunchnet         | Cyan / blue  | `lifepunch-ops.exe`  |
| Bitcoin operator            | HASHD                | Amber        | hashd rig control    |

**Design Law (non-negotiable):**

These colors identify **gameplay lanes and machine roles**.  
They are **not interchangeable cosmetic themes**.

- Green, red, and cyan are **role identities** — not VIP/EVIP/donor options.
- HASHD donor cosmetics for Bitcoin must remain within amber/gold/warm white/bronze/dark graphite/subtle metallic/controlled accents/scanline variants/approved sound packs.
- Full Cornerman green, VENGEANCE red, or lifepunchnet cyan-blue **must never** be applied to Bitcoin Terminal or Hub surfaces.

Violation risks:
- Blurring player role recognition
- Undermining the terminal brand matrix
- Donor cosmetics resembling privileged gameplay lanes
- Reduced warning/security-state readability

**Reserved state colors always override cosmetics:**
- Warning, Error, Hacked, Offline, Booting, Security alert.

---

## HASHD Donor Cosmetic Range (Allowed)

- Amber / Gold / Warm white / Bronze / Dark graphite
- Subtle supporter badges
- Controlled metallic trim
- Scanline intensity variants
- Approved sound packs
- Small RGB accents that **do not** replace machine-state colors

---

## Asset Handling Rules

- OneDrive folders = owner intake/reference.
- No runtime references to OneDrive paths in repo or compiled addons.
- Do not copy these assets into active `lpbitcoin` implementation paths.
- Hacker and Government production code paths remain **quarantined** (see `QUARANTINE_REGISTER.md` and `ACTIVE_WORKSTREAM.md`).
- When a lane is promoted (post Bitcoin Law 10), import via proper repo staging + provenance workflow (`PACKAGE_STAGING_LAYOUT.md`, `MODEL_INTAKE_DROP_MAP.md`).
- Reference is allowed now for terminal-brand planning, CRT pattern design, and LCD child planning.

---

## RED ADDENDUM (integrated 2026-06-25)

(Full text of the clean Red Addendum block previously prepared for continuity notes, `ARCHITECT_CURRENT_STATE.md`, and DECISION-0010.)

> [The complete Red Addendum text from the 2026-06-25 session is carried forward verbatim in the commit history and in the owner's continuity notes. It includes the three-surface impact (HUB / TERMINAL DEFENSE / TERMINAL APPEARANCE / GPU RACK) and the explicit instruction that no code is generated from this amendment.]

---

## Feasible DXRP Working Launch Path

**Goal:** Deliver a working, proprietary LIFEPUNCH Bitcoin mining package on DXRP servers first (modular, under ~300 MB per drop), while preserving the visual identity doctrine so that future Hacker / Government lanes feel distinct and the Bitcoin surfaces never impersonate them.

### Current Active Lane (Bitcoin / lpbitcoin)

- **Package:** `lifepunchbitcoin` (repo ident `bitcoinmining`, s&box `lifepunch.bitcoin`)
- **Entities in flight:** `bitcoinhub` (Phase A), `hashdterminal` (Phase B locked until H10), `gpurack` + `advancedgpurack` (Phase C)
- **First DXRP ship target:** Bitcoin hub + terminal + racks as the reference cyber machine system. Other cyber lanes (Hacker, Banker, Gov) are explicitly blocked until Law 10 exit.

### How the Visual Doctrine is Enforced on Launch

**1. Universal Upgrades Tab (Bitcoin Step 1 planning surface)**

When the Upgrades top tab + sub-tabs (HUB / TERMINAL / GPU RACK) are authorized as a Phase A UI shell:

- **HUB sub-tab** — HASHD amber administrative / policy operations only.
- **TERMINAL → DEFENSE sub-tab** — HASHD amber civilian security progression (firewall tiers, intrusion alerts, encryption policy, command auth, log retention). Transient hostile indicators (green/red/cyan) allowed **only** during active attack/breach visualization states.
- **TERMINAL → APPEARANCE sub-tab** — HASHD-safe donor themes exclusively. No full green/red/cyan machine impersonation.
- **GPU RACK sub-tab** — Industrial hardware language. Donor RGB presets subordinate to machine state (OFF / WARNING / ERROR / HACKED).

This is the primary place the doctrine becomes visible to players on first launch.

**2. HASHD Terminal CRT + LCD Screens**

- The CRT uses the gray/amber HASHD identity (`rig0>` prompt family).
- LCD / monitor-face content (the `screen/` slots from the OneDrive packs) can be referenced for planning the Bitcoin terminal's in-world display, but must stay within HASHD-safe color language.
- The three full CRT identity packs (Cornerman, VENGEANCE, lifepunchnet) are **future lane assets** — they inform the shared "Ops CRT" pattern (`branding/OPS_CRT_TERMINAL_THEMES.md`) but are not applied to Bitcoin surfaces.

**3. Hub Admin Panel (LpHashdPanel)**

- Retains HASHD amber ops chrome.
- Donor cosmetics (VIP/EVIP skins, sounds, limited RGB) are layered on top but never replace the base amber identity or state colors.

**4. Publish & DXRP Reality**

- `DXRP_ADDON_PUBLISH_DOCTRINE.md` + `PACKAGE_STAGING_LAYOUT.md`: folder name = entity slug.
- Modular drops preferred: hub package first (small), then terminal + racks.
- Owner controls portal presentation (names, market rows). Agents deliver working `lpbitcoin/{bitcoinhub,hashdterminal,gpurack}` trees with compiled `_c`.
- Size cap (<300 MB per chunk) is respected by keeping hacker/government visual packs out of the Bitcoin drop until those lanes are promoted.

### Future Lane Integration (Post Law 10)

When Bitcoin reaches Law 10 and Hacker / Government lanes are unlocked:

- Import the appropriate OneDrive packs through the documented intake path (not direct OneDrive references).
- Apply:
  - `hackerassets` (green) → standard `hacker-terminal` + `server-rack` (Cornerman)
  - `advancedhackerassets` (red) → advanced `advanced-hacker-terminal` + `advanced-server-rack` (VENGEANCE)
  - `governmentandpolicehackerassets` (cyan) → government terminal + server rack (lifepunchnet)
- LCD children on those terminals can directly use the `screen/` assets for flavorful in-world output.
- The same three-surface law (Hub / Terminal / Rack) + color doctrine applies symmetrically.

### Source 2 / s&box Editor Readiness (for Grok + future work)

All planning and future implementation must respect current LifePunch patterns (June 2026):

- ModelDoc first (standalone studio lane preferred).
- Child GameObjects for moving parts (fans, etc.) rather than heavy body rigging in Phase 1.
- Material slots kept distinct (`use_global_default = false` where needed).
- Emissive / self-illum driven at runtime via vmat params + C# for state (not just baked).
- CRT / LCD faces: either lightweight WorldPanel or material-driven texture updates on child planes.
- Collision: BoxCollider baseline now → multiple convex hulls authored in ModelDoc later.
- UI: `ScreenPanel` for full admin panels; typed command authenticity on physical terminals.
- Pre-compile `_c` for dedicated server; use `prepare-publish.ps1` + asset pull scripts.

Grok (and other agents) will be routed through these constraints when implementing UI shells, LCD planning, or terminal function surfaces.

---

## Related & Superseded

- `TERMINAL_BRAND_MATRIX.md` — primary identity table (now references this doctrine).
- `BITCOIN_UPGRADE_TAXONOMY.md` — Terminal section updated for defense vs appearance split.
- `BITCOINMINING_DONOR_PERKS.md` — explicit color restrictions added.
- `LIFEPUNCH_CYBER_ECOSYSTEM.md` — UI families marked as cross-addon identity anchors.
- `ACTIVE_WORKSTREAM.md` + `BITCOIN_SHIP_ROADMAP.md` — remain the execution gates.
- `QUARANTINE_REGISTER.md` — Hacker and Government lanes stay blocked.

**This document is planning and reconciliation input only.** It does not authorize implementation slices on quarantined lanes.

---

*Integrated into Architect reconciliation, DECISION-0010 draft path, and repo knowledge on 2026-06-25.*
