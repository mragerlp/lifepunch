# Cornerman task — Bitcoin mining sound sourcing (distill)

**Lane:** Tier-3 prep (distill) · **Priority:** **P1d**  
**Issued:** 2026-06-12 · **Red:** VENGEANCE intakes owner picks + authors `.sound` in ModelDoc  
**You do NOT:** download/commit WAVs into the monorepo, open s&box, `git push`, or patch C#.

---

## Question to answer

**What audio should the owner license or record for each wired bitcoinmining slot — and where can we legally source candidates?**

Ship tree today: `sounds/bitcoinminer/README.md` only — **no binaries, no `.sound`**.

---

## Read first (in order)

| # | Path | Why |
|---|------|-----|
| 1 | `addons/Assets/addons/lifepunch/bitcoinmining/sounds/bitcoinminer/README.md` | Slot names + IP law |
| 2 | `addons/Code/Addons/lifepunch/bitcoinmining/BitcoinMiningAddon.cs` | Path constants (wired) |
| 3 | `addons/scripts/Intake-BitcoinMinerSounds.ps1` | Drop names + intake flow |
| 4 | `addons/Code/Addons/lifepunch/bitcoinmining/BitcoinMinerHubEntity.cs` | Hub power SFX hooks |
| 5 | `addons/Code/Addons/lifepunch/bitcoinmining/GpuRackEntity.cs` | Rack hum / glitch / error |
| 6 | `addons/Code/Addons/lifepunch/bitcoinmining/HashdTerminal.razor` | Keyboard SFX on UI |
| 7 | `addons/Assets/addons/lifepunch/ak47/sounds/ak47_shot.sound` | Working `.sound` JSON pattern |
| 8 | `addons/docs/briefs/BITCOINMINING_PROTECTION_CHECKLIST.md` | No third-party pack rip |

---

## Wired slots (P0 — code already calls these)

| Slot file stem | Constant | Trigger | Audio spec |
|----------------|----------|---------|------------|
| `hub-startup` | `HubStartupSoundPath` | Hub power **on** | Short boot chirp / relay click (0.5–2s, one-shot) |
| `hub-fan-loop` | `HubFanLoopSoundPath` | While hub powered | Seamless loop, low server-fan hum, not overpowering |
| `hub-fan-down` | `HubFanDownSoundPath` | Hub power **off** | Fan spin-down / power relay (1–3s, one-shot) |
| `server-hum` | `HumSoundPath` | Rack **mining** loop | Data-center / GPU coil whine, seamless loop |
| `keyboard` | `KeyboardSoundPath` | HASHD UI keys / numpad | **Loud click typing** — mechanical, punchy, RP-audible (owner ask). Amber HASHD tone; not whisper-quiet; distinct from hacker green phosphor |
| `glitch` | `GlitchSoundPath` | Rack damage sequence | Digital glitch burst (short) |
| `error` | `ErrorSoundPath` | Rack error beep | Single denial beep |

**Optional (intake script only — not wired in C# yet):** `metal-hit`, `smoke`, `explode` — note in deliverable as P2.

---

## Task S-1 — Per-slot creative brief

**Output section in `outbox/BITCOINMINING_SOUND_SLOT_SPEC.md`**

For each P0 slot, one subsection:

- **Mood** (1 sentence — RP fantasy: “Ophion desk waking up”, not generic UI click)
- **Technical** — mono/stereo, target length, loopable Y/N, max file size guidance
- **Mix** — suggested relative loudness vs `server-hum` (keyboard quieter, startup punchier)
- **Search keywords** (5–10 terms for libraries / Freesound / Artlist-style browsing)
- **Anti-patterns** — what *not* to use (bitcoin ASMR, casino coins, third-party miner pack SFX)

---

## Task S-2 — Shortlist (research only)

**Output:** `outbox/BITCOINMINING_SOUND_SHORTLIST.md`

Table per slot — **3–5 candidate directions each** (not necessarily one file):

| Slot | Source type | Candidate name / URL | License class | Owner action |
|------|-------------|----------------------|---------------|--------------|
| hub-startup | e.g. CC0 library | … | CC0 / paid / record | BUY / RECORD / SKIP |

**License classes you may recommend:**

- **RECORD** — owner records original (preferred for ship safety)
- **CC0** — public domain, link + snapshot date
- **PAID** — commercial library (Artlist, Epidemic, etc.) — note tier needed
- **SKIP** — do not use (unclear license, ripped game audio, another addon pack)

**Hard rule:** Do **not** recommend audio from other s&box bitcoin mining addons or leaked game packs.

---

## Task S-3 — Cross-job console + hacker sounds (owner supplement)

**Read inbox:** `CORNERMAN_CYBER_CONSOLE_SOUNDS_SUPPLEMENT.md`, `OWNER_ASK_UNIVERSAL_CONSOLE_KEYBOARD.txt`, `OWNER_ASK_GPU_FAN_LIFECYCLE.txt`, `OWNER_ASK_HACKERJOB_SOUNDS.txt`

**Output sections in `BITCOINMINING_SOUND_SLOT_SPEC.md`:**

- **§ Universal console keyboard** — one loud click for HASHD + hacker terminals + future gov consoles (`lifepunch-console-keyboard` shared path)
- **§ GPU fan lifecycle** — ramp-up / seamless loop / ramp-down; code ramps volume over ~8s (`GpuRackEntity`, `BitcoinMinerHubEntity`)
- **§ Hacker Job matrix** — boot, access granted/denied, rack fans, scan pulse (see hacker ask file); keyboard = same universal pick

---

## Task S-4 — Intake + ModelDoc checklist for Red

**Output:** `outbox/BITCOINMINING_SOUND_INTAKE_CHECKLIST.md`

Step list after owner drops WAVs in `%USERPROFILE%\Downloads\bitcoinminer-sounds\`:

1. Run `Intake-BitcoinMinerSounds.ps1`
2. Compile `.vsnd` in s&box
3. Author `.sound` per slot (mirror `ak47_shot.sound` structure)
4. Verify paths match `BitcoinMiningAddon.cs` exactly
5. Smoke: `lp_spawn_bitcoin_miner_hub` → `lp_hub_power 1` (hub SFX) → `lp_hashd_pin_preview setup` (keyboard) → `mining start` (hum)
6. Prefab: re-enable hub sound props if nulled in playtest doc

---

## Deliverables (required)

Write to `C:\lifepunch\cornerman\outbox\`:

| File | Contents |
|------|----------|
| `BITCOINMINING_SOUND_SLOT_SPEC.md` | S-1 + S-3 |
| `BITCOINMINING_SOUND_SHORTLIST.md` | S-2 |
| `BITCOINMINING_SOUND_INTAKE_CHECKLIST.md` | S-4 |

Ping Red one line: `OK cornerman bitcoinmining sounds P1d — N slots shortlist, M CC0 candidates`

---

## Model

**WarmDistill** only. No C#.
