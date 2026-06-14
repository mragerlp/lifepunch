# CVL / GRB — RGB integration doctrine

> **June 2026.** This is systems-integration law, not a nickname for "all three agents."
> Uniform colors are **primary channels**. The **rainbow** is what emerges when channels mix at
> the right intensities — we are at **standard RGB** today; full gradient maturity comes later.

## Primaries (the three pixels)

| Channel | Node | RGB | Role |
|---------|------|-----|------|
| **R** | **VENGEANCE** | `(255,0,0)` | Red — decide, integrate, GitHub, universal command, hub token holder |
| **G** | **Cornerman** | `(0,255,0)` | Green — capture, PTT, Tier-3 prep, feed signals **up** (no secrets) |
| **B** | **lifepunchnet** | `(0,0,255)` | Blue — host STT, logs, firewall, session hub, future Odysseus |

Pure primaries alone are **necessary but not sufficient**. A node can be "lit" while the system is still not white.

## Directed pings (source → destination)

Every CVL action is a **directed ping**: one **source** node signals one **destination** node.

**Notation:** `R → G` = VENGEANCE pings Cornerman. Read it as **source tier → destination tier**, not
"shortcut color" and not "where the `.lnk` file lives."

### The six pairwise directions

| Ping | Plain English | Who initiates | Who receives | Shortcut / launcher icon |
|------|---------------|---------------|--------------|---------------------------|
| **R → G** | VENGEANCE → Cornerman | Red desk | Green worker | **Green** on Red desktop |
| **G → R** | Cornerman → VENGEANCE | Green worker | Red desk | **Red** on Green desktop |
| **R → B** | VENGEANCE → lifepunchnet | Red desk | Blue host | **Blue** on Red desktop |
| **B → R** | lifepunchnet → VENGEANCE | Blue host | Red desk | **Red** on Blue desktop *(pull/status)* |
| **G → B** | Cornerman → lifepunchnet | Green worker | Blue host | **Blue** on Green desktop *(STT POST)* |
| **B → G** | lifepunchnet → Cornerman | Blue host | Green worker | **Green** on Blue desktop *(STT result / ack)* |

**Icon rule (non-negotiable):** the shortcut you double-click uses the **destination** tier color —
where the signal **lands** — even when the `.lnk` sits on a different machine.

### Canonical examples (structured workflow)

| Ping | Example on the wire | Correct shortcut pairing |
|------|---------------------|---------------------------|
| **R → G** | SSH-start PTT relay on Cornerman | **VENGEANCE desktop:** green **Cornerman - Talk to Vengeance** |
| **R → G** (workflow) | `Send-CornermanWorkflow.ps1` → `C:\lifepunch\cornerman\inbox\` + SSH execute | Red dispatches; Green needs no Cursor |
| **G → R** | Outbox → Voice Watch → Cursor paste | **Cornerman desktop:** red **Talk to Vengeance** |
| **R → B** | Session sync, hub ingest, lifepunchnet watch | **VENGEANCE:** blue **lifepunchnet (RDP)** + watch windows |
| **B → R** | `:9101` status, `:9102` hub tail (Bearer) | Red pulls; no tumble back to Green |
| **G → B** | Mic audio → Whisper `:9000` | Runs inside Green relay (cyan leg) |
| **B → G** | Transcription JSON back to relay | Return leg on same voice round |

**Wrong:** red **Talk to Vengeance** on the VENGEANCE desktop — that collapses **G → R** (destination Red)
with **R → G** (you commanding Green). Fixed June 2026: Red commands Green with a **green** launcher.

### Directed ping vs mix color

Do not confuse **who pings whom** with **additive mix** (collaboration hue):

| Concept | Meaning | Example |
|---------|---------|---------|
| **R → G** ping | Red commands / reaches Green | Start relay on Cornerman |
| **Yellow** mix | R + G collaboration path lit | Full PTT → paste loop working |
| **G → B** ping | Green sends work to Blue | Audio to Whisper |
| **Cyan** mix | G + B path lit | STT + archive alive |
| **R → B** ping | Red writes / polls Blue | Hub ingest, watchdog |
| **B → R** ping | Blue reports to Red | Status API, hub tail |
| **Magenta** mix | B + R path lit | Token auth + checkpoint OK |

Mix = **path health**. Ping = **one hop** on that path. Rainbow (later) = many logged pings + mixes over time.

## Pairwise mixes (two-channel collaboration)

Additive mixing — **adding signal**, not pasting chat between agents:

| Mix | RGB logic | CVL meaning | Example path |
|-----|-----------|-------------|--------------|
| **Yellow** | R + G | Desk + worker | PTT → Cornerman outbox → VENGEANCE watch → Cursor paste |
| **Cyan** | G + B | Worker + host | Mic → lifepunchnet Whisper `:9000` → session-sync → hub |
| **Magenta** | B + R | Host + desk | lifepunchnet `:9101/:9102` ↔ VENGEANCE checkpoint / security gate |

If a mix is wrong, you see **that color's symptom** — not generic "CVL broken."

## Full integration

| State | RGB | CVL meaning |
|-------|-----|-------------|
| **White** | R+G+B full | Universal go — `Invoke-CvlUniversal.ps1`, Start Day, security gate PASS, hub ingest allowed |
| **Black** | 0,0,0 | No trustworthy signal — node down, auth fail, firewall block, or tumble |

**Rainbow** = smooth gradient across mixes over time (logged hub history, Odysseus reading tier-tagged NDJSON, checkpoints forming a cycle). **We are not rainbow yet** — we are wiring **standard RGB** (primaries + pairwise paths + white checkpoint).

## Opsec: rainbow deceives outsiders, not us

A monitor fakes a natural spectrum by mixing three primaries — observers see millions of **approximate**
colors, not separate R/G/B subpixels. Attackers probing CVL from the internet should see the same kind of
**wrong-color noise**: scoped firewall, Bearer auth, IP allowlists, no hub read-back tumble, tier-tagged
logs — not "VENGEANCE," "Cornerman," or "lifepunchnet" as true identities.

| What outsiders may see | What they must not get |
|------------------------|-------------------------|
| HTTP on scoped ports | Open `:9000/:9101/:9102` to the world |
| Bearer without TLS (LAN-scoped) | Hub token on Green or in chat |
| Generic `administrator` RDP noise | Writable git creds or secrets on Blue |
| Mixed traffic / failed probes | A faithful map of R+G+B channel wiring |

**Black** = no signal (block, auth fail). **False color** = probe succeeded but channel identity is
obscured — that is intentional. **White** = we know all three primaries are lit; outsiders still do not.

**Odysseus** (Blue, later) reads **tier-tagged hub memory** (`vengeance` | `cornerman` | `lifepunchnet` |
`universal`) and optional `mix` fields — it conducts long-context prep for Red from **true channel state**,
not from whatever color an attacker guessed at the firewall.

## How the system tells itself (diagnostic)

`Get-CvlUniversalCheckpoint.ps1` / `Invoke-CvlUniversal.ps1` should report **which channels are lit**:

- **R dim** — VENGEANCE git dirty/ahead, security gate fail, no token config
- **G dim** — Cornerman relay missing, SSH fail, outbox empty
- **B dim** — Whisper down, hub unreachable, firewall not scoped
- **Yellow path broken** — G lit but R watch dead (voice without paste)
- **Cyan path broken** — G lit but B STT timeout (PTT without transcription)
- **Magenta path broken** — B hub up but R cannot auth (token/firewall/IP allowlist)

Do not label a shortcut or doc "rainbow" until white-light integration is routine. **Universal (tri-stack)** icon = **target white**, not "we already have a rainbow."

## Team rounds (Red's arm)

When non-blockers still need lane work, **Red does not solo-fix everything on Green/Blue.**

1. **VENGEANCE:** `Get-CvlTeamRoundPaste.ps1` — reads live checkpoint gaps, prints **one paste** for both lanes.
2. **Same paste** to Cornerman **and** lifepunchnet (shared situational awareness).
3. **No dual replies** — only `BLOCKED <lane>: reason` if stuck.
4. **Bloodwave:** "both lanes done" → `Invoke-CvlUniversal.ps1 -IngestToHub -Note <ping-id>` = **single answer**.
5. **Odysseus** (later) reads hub tier lines from that ping — you stop merging agent essays.

## Communication law (anti-tumble)

1. **Hub is blue memory** — append-only on lifepunchnet. Green feeds via Red bridge. **No node reads hub and re-posts to another node.**
2. **Red conducts checkpoints** — one universal answer for Bloodwave; auto-probe, not three Cursor paste hunts.
3. **Green never holds blue tokens** — LAN worker only.
4. **Blue never decides GitHub** — host + log + STT; integration stays on Red.
5. **Security before intensity** — `Test-CvlSecurity.ps1` before high-value hub ingest. Dim channels stay dim; do not fake white.

## Hub log fields

Session hub NDJSON uses `tier`: `vengeance` | `cornerman` | `lifepunchnet` | `universal`.

Optional future fields for Odysseus / rainbow:

| Field | Values | Meaning |
|-------|--------|---------|
| `mix` | `yellow` \| `cyan` \| `magenta` \| `white` \| `black` | Path health (additive) |
| `ping` | `r→g` \| `g→r` \| `r→b` \| `b→r` \| `g→b` \| `b→g` | Directed hop that produced the line |

## Related

- `diagrams/cvl-missing-link-v2.png` — CVL chart v2 (authoritative raster)
- `diagrams/cvl-missing-link-v2.drawio` — editable v2 (ops IPs in footer)
- `diagrams/cvl-rgb-directed-ping.drawio` — v1 ecosystem chart (directed pings)
- `OPS_CLARITY_CHECKPOINT.md` — shortcuts, uniforms, voice stack
- `session-hub/README.md` — blue host log + security
- `Invoke-CvlUniversal.ps1` — universal white-light probe
- `Get-CvlTeamRoundPaste.ps1` — one paste for Green + Blue from live gaps (Red's arm)
- `Send-CornermanWorkflow.ps1` — Red dispatches whitelisted work to Green over SSH (inbox + ack; no Cursor on Cornerman)
- `Get-CornermanWorkflowStatus.ps1` — Red reads Green inbox/ack tail
- `Get-CvlOdysseusRoundPaste.ps1` — one paste for Odysseus install round on Blue
- `Test-CvlSecurity.ps1` — signal hardening before ingest
