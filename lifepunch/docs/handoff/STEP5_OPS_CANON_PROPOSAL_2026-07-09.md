# STEP 5 — OPS canon PR PROPOSAL (deferred, not committed)

**Why proposed, not executed:** three preconditions of the ruled STEP 5 are unmet, and the
next queue item is the workflow doctrine that governs how canon docs are written
(reconcile-not-append, cite every replacement). Executing doc edits before reading it, and
canonizing an unproven transport, would be backwards. Precise ready-to-apply edits below;
Bloodwave confirms targets + unblocks, then this lands in minutes.

Every proven claim carries its sensor. `develop` @ `8532aae`.

---

## BLOCKERS (each needs a ruling or an unblock)

1. **`model-endpoints.json` is Green-side and unreachable.** The relay names
   `C:\lifepunch\cornerman\config\model-endpoints.json`. That path is on **Cornerman (Green)**,
   not the Red repo (`C:\Users\jared\Projects\lifepunch`). It does not exist on Red; I cannot
   edit it. It is also explicitly **not** the catalog file — the repo catalog is
   `lifepunch/config/cornerman-tier3-models.json` (CORNERMAN_MODEL_ROUTING.md:46), which is
   models, not endpoints. → **Bloodwave or Green edits the runtime endpoint file on the box.**
   This PR canonizes the REPO docs that record the endpoint.

2. **G: repoint is auth-blocked — cannot be canonized as DONE.** STEP 4 failed: the stored
   `10.10.10.2` credential's username is the bare Outlook email `JARED.ZERILLO@OUTLOOK.COM`,
   which SMB rejects (STATUS_LOGON_FAILURE). SMB/445 over the link is OPEN (proven), so this is
   auth only. Writing "G: → \\10.10.10.2\cornerman-inbox, SHA256 clean" would be FALSE — the
   repoint has not happened. → **The G: canon line is DEFERRED until the credential is fixed
   (SMB-valid username: `MicrosoftAccount\jared.zerillo@outlook.com` or Green's
   `COMPUTERNAME\localuser`) and the SHA256 probe passes.**

3. **"tri-stack hardware doc" is ambiguous — needs disambiguation.** Two candidates:
   - `lifepunch/docs/LOCAL_AI_WORKSTATION.md` — the hardware/firewall guide (Corsair AI
     Workstation 300, Ryzen AI Max 385 / **Radeon 8050S**, firewall §6). The link topology +
     DISPLAY-proven note fit here naturally.
   - `lifepunch/docs/GREEN_EXECUTION_MODEL.md` — the "three agent groups" model
     (Red / Cornerman / MacBook). "Tri-stack" matches this name, but its hardware is a table,
     not a networking diagram.
   → **Which doc gets the Red↔Green link diagram?** I lean LOCAL_AI_WORKSTATION.md (it owns the
   firewall/networking section and names the Radeon that the DISPLAY proof enumerated).

---

## READY-TO-APPLY EDITS (proven, unambiguous — pending doctrine-brief GO on doc-writing style)

### A. Endpoint: direct-link primary, LAN fallback — `CORNERMAN_MODEL_ROUTING.md:176`

REPLACE the "LAN today" row:
> | **LAN today** | Red still uses `Send-CornermanWorkflow.ps1` + SSH to warm models on Green; direct `http://192.168.1.229:1234` also works on subnet |

WITH (reconciled, not appended — the direct link becomes primary, LAN retained as documented fallback):
> | **Primary endpoint** | Direct point-to-point link — `http://10.10.10.2:1234` (Red 10.10.10.1 ↔ Green 10.10.10.2, unrouted, LM Studio bound 0.0.0.0:1234, firewall-scoped to 10.10.10.1). |
> | **LAN fallback** | `http://192.168.1.229:1234` on the subnet (documented fallback); `Send-CornermanWorkflow.ps1` + SSH warm path unchanged. |

Sensor: SERVE asserted over `10.10.10.2` — `/api/v0/models` shows `qwen/qwen3.6-35b-a3b` `state=loaded`; LINK 0.36–0.54 ms (Stopwatch), TTL=128 single hop.

### B. Single-model law, sharpened — `CORNERMAN_MODEL_ROUTING.md:48`

REPLACE:
> **Loaded vs catalog:** LM Studio `/v1/models` lists every downloaded model even when not in VRAM. Trust `lms ps` (or warm-script output `LOADED in VRAM`) — not the GUI progress bar stalling at ~97%.

WITH:
> **Single-model law (sharpened 2026-07-09):** the law governs **one loaded GENERATIVE model**
> (`type=vlm|llm`). Assert exactly one loaded generative via `/api/v0/models` `state=loaded`
> — NOT `/v1/models`, which lists every *downloaded* model (the catalog roster, correctly 4).
> `type=embeddings` is **EXEMPT** (nomic-embed, ~84 MB, different weight class, drift-scanner
> dependency) and may be loaded alongside. Trust `lms ps` for VRAM residency, not the GUI bar.

Sensor: over the link, loaded generative = 1 (`qwen3.6-35b-a3b`), loaded embeddings = 1
(exempt) → SERVE PASS. `/v1/models` returned 4 (downloaded roster, correct).

### C. Link topology + DISPLAY-proven — the "tri-stack" doc (target TBD, see blocker 3)

ADD a networking subsection:
> **Red ↔ Green direct link (2026-07-09).** Second 2.5GbE adapter per box, patch cable, no
> switch. Red `Ethernet 2` (Realtek USB 2.5GbE) = 10.10.10.1/24; Green `Ethernet 4` =
> 10.10.10.2/24. No gateway, no DNS on either — the unrouted link IS the isolation. Firewall:
> inbound TCP 1234 + TCP 445 + ICMPv4, each scoped to the peer address only, `-Profile Any`
> (a gateway-less link lands in the Public profile, so Private-only rules never apply). LAN
> adapters (.236 / .229) retained as documented fallback.
> **DISPLAY:** Green's HDMI dummy plug is seated — post-headless probe enumerates **AMD Radeon
> 8050S** alongside the Microsoft Remote Display Adapter (the 32 Hz RDP virtual display). Blank
> refresh on the Radeon = no-EDID dummy, expected.

### D. EOL-aware sensor note — wherever the sync/transport integrity is documented

ADD:
> **EOL-aware compare.** Red repo is LF; the Green/editor trees are CRLF. Transport/drift checks
> MUST compare content ignoring line endings (`diff <(tr -d '\r' A) <(tr -d '\r' B)`) — a raw
> hash reports every file as drift and is wrong. Proven: LF files compile in the editor tree
> (the razor sync flipped both to LF, three clean compiles).

---

## What lands where, once unblocked

| edit | doc | status |
|------|-----|--------|
| A endpoint primary/fallback | CORNERMAN_MODEL_ROUTING.md:176 | ready |
| B single-model law | CORNERMAN_MODEL_ROUTING.md:48 | ready |
| also endpoint | CORNERMAN_LM_STUDIO.md (§ bind, env vars) | ready — multiple `.229` refs to reconcile |
| C link topology + DISPLAY | LOCAL_AI_WORKSTATION.md **or** GREEN_EXECUTION_MODEL.md | **target TBD** |
| D EOL note | same as C, or CONFIG_SOURCE_OF_TRUTH.md | **target TBD** |
| model-endpoints.json | `C:\lifepunch\cornerman\config\` (Green) | **Bloodwave/Green — off-repo** |
| G: repoint canon line | wherever transport is recorded | **DEFERRED — STEP 4 auth-blocked** |

Nothing committed. Awaiting: doc-target rulings (blocker 3), STEP-4 credential fix (blocker 2),
and the item-4 doctrine brief (governs how these canon edits are written).
