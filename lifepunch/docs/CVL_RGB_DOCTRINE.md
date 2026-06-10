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
4. **Mr. Rager:** "both lanes done" → `Invoke-CvlUniversal.ps1 -IngestToHub -Note <ping-id>` = **single answer**.
5. **Odysseus** (later) reads hub tier lines from that ping — you stop merging agent essays.

## Communication law (anti-tumble)

1. **Hub is blue memory** — append-only on lifepunchnet. Green feeds via Red bridge. **No node reads hub and re-posts to another node.**
2. **Red conducts checkpoints** — one universal answer for Mr. Rager; auto-probe, not three Cursor paste hunts.
3. **Green never holds blue tokens** — LAN worker only.
4. **Blue never decides GitHub** — host + log + STT; integration stays on Red.
5. **Security before intensity** — `Test-CvlSecurity.ps1` before high-value hub ingest. Dim channels stay dim; do not fake white.

## Hub log fields

Session hub NDJSON uses `tier`: `vengeance` | `cornerman` | `lifepunchnet` | `universal`.

Optional future field: `mix` = `yellow` | `cyan` | `magenta` | `white` | `black` for Odysseus queries.

## Related

- `OPS_CLARITY_CHECKPOINT.md` — shortcuts, uniforms, voice stack
- `session-hub/README.md` — blue host log + security
- `Invoke-CvlUniversal.ps1` — universal white-light probe
- `Get-CvlTeamRoundPaste.ps1` — one paste for Green + Blue from live gaps (Red's arm)
- `Get-CvlOdysseusRoundPaste.ps1` — one paste for Odysseus install round on Blue
- `Test-CvlSecurity.ps1` — signal hardening before ingest
