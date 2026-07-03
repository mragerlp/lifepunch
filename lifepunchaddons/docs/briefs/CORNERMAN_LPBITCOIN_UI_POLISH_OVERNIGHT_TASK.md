# Cornerman overnight — LPBitcoin UI polish + July ship prep (~12h)

**Issued:** 2026-06-20 · **Owner away until ~11:59 PM EST**  
**Lane:** Tier-3 distill + SCSS drafts · **Red (VENGEANCE) ships C# after owner playtest**  
**Gate:** `ACTIVE_WORKSTREAM.md` — `lifepunchbitcoin` only · Hacker blocked until bitcoin UI signed off

---

## Eyes covered (mandatory)

**Cornerman's eyes are covered** — no Claude Bridge, no flatgrass, no screenshots unless owner pasted them.
All outputs are **drafts for Red** to implement on VENGEANCE. Do not claim playtest pass.

---

## Red just landed (read on Green after `MonorepoPull`)

| Area | Change | Owner must verify (Stop → Play) |
|------|--------|----------------------------------|
| Terminal scroll | Native `overflow-y: scroll`; removed `_logRevision` from `BuildHash` | `help` → wheel up stays up; scale change OK |
| Hub panels | Flat empty callout (no nested radius “ears”) on Active miners / GPU racks | Corner ears gone; title aligns with panel |

**Files:** `LpBitcoinTerminalPanel.razor` · `.razor.scss` · `LpHashdPanel.razor.scss`

---

## Goal (July ship)

Polish **Hub → Terminal → GPU rack** loop so a new player completes it without help + flatgrass proof.
Gameplay depth can follow; **UI uniformity and scroll reliability** block publish.

---

## Read first (in order)

| # | Path | Why |
|---|------|-----|
| 1 | `lifepunchaddons/docs/ACTIVE_WORKSTREAM.md` | Hard gate |
| 2 | `lifepunchaddons/docs/TERMINAL_BRAND_MATRIX.md` | Hub/terminal wording + colors |
| 3 | `lifepunchaddons/docs/SBOX_RAZOR_SCSS_RULES.md` | Flex-only, class root, no `display:none` |
| 4 | `lifepunchaddons/Code/Addons/lifepunch/bitcoinmining/LpBitcoinTerminalPanel.razor` | CRT reference |
| 5 | `lifepunchaddons/Code/Addons/lifepunch/bitcoinmining/LpHashdPanel.razor` | Hub monolith (~1700 lines) |
| 6 | `lifepunchaddons/Code/Addons/lifepunch/LifePunchUiShell.scss` | Shared tokens |
| 7 | `lifepunchaddons/Code/Addons/lifepunch/bitcoinmining/LpUiMenuLayout.scss` | CRT layout tokens (hub should import) |
| 8 | `lifepunchaddons/docs/TECH_DEBT.md` | UI-03 hub host extraction |
| 9 | `lifepunchaddons/docs/bitcoinmining/docs/BITCOINMINING_POLISH_CHECKLIST.md` | H*/T*/R* IDs |

---

## Deliverables (outbox only)

Write to **`C:\lifepunch\cornerman\outbox\`** (Green) — Red pulls via RAG / morning review.

| Block | Est. | Output file | Content |
|-------|------|-------------|---------|
| **A** | 1.5h | `LPBITCOIN_TERMINAL_SCROLL_ACCEPTANCE.md` | Step-by-step playtest script; failure modes; “done when” for owner sign-off |
| **B** | 1.5h | `LPBITCOIN_HUB_PANEL_ALIGNMENT_AUDIT.md` | Screenshot checklist (Active miners, GPU racks, wallet, transfers); flat SCSS fix list with selectors |
| **C** | 2h | `LPBITCOIN_HUB_TERMINAL_PARITY_MATRIX.md` | Every hub action ↔ CRT command; linking language; rack deposit flow |
| **D** | 2h | `LPBITCOIN_UI_SHELL_UNIFORM_PLAN.md` | One chrome stack: header/footer/sidebar tokens; hub imports `LpUiMenuLayout.scss`; font/spacing law |
| **E** | 1.5h | `LPBITCOIN_HASHD_HOST_EXTRACTION_DRAFT.md` | `LpHashdPanelHost` skeleton (StaffMenu pattern); file split map; no C# ship |
| **F** | 1h | `LPBITCOIN_RAZOR_SCSS_VALIDATION_REPORT.md` | Run mental pass vs `Validate-SboxRazorScss.ps1` rules on hashd + terminal; list violations |
| **G** | 1h | `LPBITCOIN_JULY_PUBLISH_CHECKLIST.md` | Portal, `_c` assets, flatgrass proof package, owner H10 sign-off gates |
| **H** | 1h | `BITCOINMINING_JOB_ROLEPLAY_ONE_PAGER.md` | (if not done) Miner class fantasy: hub PIN, terminal rig0, passive racks |
| **I** | 0.5h | `BITCOINMINING_SOUND_SHORTLIST.md` | Keyboard, hub power, rack fan states — file paths + trigger hooks |

**Optional coder block (WarmCoder):** `LPBITCOIN_HUB_PANEL_SCSS_PATCH.scss` — flat rules only for remaining alignment ears (Red pastes after review).

---

## Do NOT

- Commit to GitHub (Green is read-only handoff)
- Run s&box editor, ModelDoc compile, or DXRP play
- Touch Hacker / Banker / weapons lanes
- Expand scope beyond Hub · Terminal · GPU rack UI polish

---

## Model routing

| Work | Model |
|------|-------|
| Blocks A–D, G–I | **distill** (`qwen/qwen3.6-35b-a3b`) |
| Block E host sketch, optional SCSS patch | **coder** (`qwen2.5-coder-32b-instruct`) — drafts only |

Red warms: `Send-CornermanWorkflow.ps1 -Action WarmDistill` then `-Action WarmCoder` before block E.

---

## Ping Red (one line when batch done)

```text
OK cornerman lpbitcoin-ui-polish-overnight @<outbox-count> files — ready for Red morning
```

---

## References

- StaffMenu scroll pattern: native `overflow-y: scroll` + `LifePunchUiScrollPolicy.Apply`
- Hub empty state markup: `LpHashdPanel.razor` → `.lp-ui-empty-callout`
- Passive rack loop: mine at rack → deposit at CRT → hub wallet (doc in parity matrix)
