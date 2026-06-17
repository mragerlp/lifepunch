# Bitcoin mining ├óΓé¼ΓÇ¥ per-slot sound spec (Cornerman distill)

**Issued:** 2026-06-12 ├é┬╖ **Lane:** P1d distill ├é┬╖ **Red:** intake + ModelDoc + compile  
**Code refs:** `BitcoinMiningAddon.cs` paths ├é┬╖ **Ship policy:** owner-licensed / CC0 / RECORD only ├óΓé¼ΓÇ¥ no third-party miner packs

---

## hub-startup

**Mood:** Ophion desk waking up ├óΓé¼ΓÇ¥ a single authoritative relay latch and brief electronic chirp, like mains engaging on a rack PDU.

| Field | Spec |
|-------|------|
| **Technical** | Mono preferred; **0.5├óΓé¼ΓÇ£2.0 s** one-shot; non-looping; 44.1 kHz / 16-bit WAV source |
| **Max size** | &lt; 500 KB after trim (short transient) |
| **Mix** | **Loudest** one-shot in the hub set ├óΓé¼ΓÇ¥ punch above `hub-fan-loop` onset by ~6 dB |
| **Search keywords** | `PDU relay click`, `server power on`, `rack mains`, `electromagnetic relay`, `breaker close`, `UPS engage`, `datacenter boot`, `single click metallic` |
| **Anti-patterns** | Windows startup jingle, BIOS beep codes, casino slot machine, ripped Facepunch UI, other s&box bitcoin addon boots |

**Trigger:** `BitcoinMinerHubEntity` ├óΓé¼ΓÇ¥ hub power **on** (`HubStartupSoundPath`).

---

## hub-fan-loop

**Mood:** Steady Ophion ventilation ├óΓé¼ΓÇ¥ always-on low server fans behind amber HASHD, not jet engine.

| Field | Spec |
|-------|------|
| **Technical** | Mono or stereo; **seamless loop** 4├óΓé¼ΓÇ£15 s slice; band-limited 200 Hz├óΓé¼ΓÇ£4 kHz hum |
| **Max size** | &lt; 2 MB loop source |
| **Mix** | Bed under UI; ~**├ó╦åΓÇÖ12 dB** vs `hub-startup`; duck 3 dB when `keyboard` fires |
| **Search keywords** | `server fan loop`, `rack cooling`, `computer ventilation`, `data center room tone`, `HVAC whir`, `PSU fan`, `1U fan steady` |
| **Anti-patterns** | Laptop coil whine only (too thin), wind/howling, ASMR bitcoin mining videos, loop with audible seam click |

**Trigger:** While hub powered (`HubFanLoopSoundPath`).

---

## hub-fan-down

**Mood:** Power shedding ├óΓé¼ΓÇ¥ fans coast down and relay opens; desk going dark.

| Field | Spec |
|-------|------|
| **Technical** | Mono; **1├óΓé¼ΓÇ£3 s** one-shot with natural decay (or crossfade tail from loop) |
| **Max size** | &lt; 800 KB |
| **Mix** | Similar peak to `hub-startup` but longer tail; no harsh clip |
| **Search keywords** | `fan spin down`, `server shutdown`, `relay off`, `power down whir`, `fan deceleration`, `PDU off`, `cooling ramp down` |
| **Anti-patterns** | Power cut pop/DC offset thump, glass break, generic ├óΓé¼┼ôpower down├óΓé¼┬¥ game sting from unlicensed packs |

**Trigger:** Hub power **off** (`HubFanDownSoundPath`).

---

## server-hum

**Mood:** GPUs hashing ├óΓé¼ΓÇ¥ dense data-center bed with subtle coil texture; ├óΓé¼┼ômoney printer├óΓé¼┬¥ without comedy.

| Field | Spec |
|-------|------|
| **Technical** | **Seamless loop** 8├óΓé¼ΓÇ£20 s; stereo OK; emphasize 120 Hz + 2├óΓé¼ΓÇ£6 kHz texture |
| **Max size** | &lt; 3 MB |
| **Mix** | Reference bed for rack proximity; ramps over **8 s** (`HumRampSeconds` in `GpuRackEntity`); max vol = 1.0 |
| **Search keywords** | `GPU mining hum`, `server room tone`, `datacenter aisle`, `rack whir`, `machine room drone`, `computer cluster`, `power supply hum` |
| **Anti-patterns** | Bitcoin ASMR, casino coins, factory conveyor, third-party miner addon loops |

**Trigger:** Rack **mining** loop (`HumSoundPath`).

---

## keyboard *(owner priority ├óΓé¼ΓÇ¥ loud click typing)*

**Mood:** HASHD amber terminal ├óΓé¼ΓÇ¥ **mechanical, punchy, RP-audible** numpad/UI taps; operator working a rig, not whisper-quiet laptop keys.

| Field | Spec |
|-------|------|
| **Technical** | Mono; **0.03├óΓé¼ΓÇ£0.12 s** per key (trim from longer takes); sharp attack; 44.1/48 kHz |
| **Max size** | &lt; 200 KB per one-shot (or 3├óΓé¼ΓÇ£5 variants in `.sound` Random mode later) |
| **Mix** | **Above** `server-hum` at terminal camera (~├ó╦åΓÇÖ6 dBFS peak); must read in open RP spaces |
| **Search keywords** | `mechanical keyboard loud`, `Cherry MX blue click`, `numpad press`, `teletype punch`, `switch snap`, `high profile keycap`, `clicky tactile`, `terminal typing` |
| **Anti-patterns** | Membrane laptop keys, mouse micro-clicks, typewriter carriage return only, hacker-pack rip, over-compressed ├óΓé¼┼ôASMR├óΓé¼┬¥ typing |

**Trigger:** `HashdTerminal.razor` ├óΓé¼ΓÇ¥ UI keys / graphical PIN numpad (`KeyboardSoundPath`).

**Production tip (RECORD):** Record 5├óΓé¼ΓÇ£8 isolated key presses + 3 rapid bursts on a clicky board (Cherry MX Blue/Green or Kailh Box White). Normalize peaks; keep transient, do not heavy limiter.

---

## glitch

**Mood:** Rack taking damage ├óΓé¼ΓÇ¥ short digital corruption, not explosion.

| Field | Spec |
|-------|------|
| **Technical** | Mono; **0.2├óΓé¼ΓÇ£1.0 s** one-shot; may be 2├óΓé¼ΓÇ£3 variants |
| **Max size** | &lt; 400 KB |
| **Mix** | Spike above `server-hum`; below `error` in annoyance (damage ├óΓÇ░┬á denial) |
| **Search keywords** | `digital glitch burst`, `bit crush`, `data corruption`, `static zap`, `buffer underrun`, `segfault sfx`, `cyber glitch short` |
| **Anti-patterns** | Long glitch drones, horror scream stingers, HDD click of death as sole asset (license noise on some Freesound HDD fail clips) |

**Trigger:** Rack damage sequence (`GlitchSoundPath` / prefab `GlitchSound`).

---

## error

**Mood:** Denied ├óΓé¼ΓÇ¥ single firm ├óΓé¼┼ôno├óΓé¼┬¥ beep for bad PIN / invalid rig command.

| Field | Spec |
|-------|------|
| **Technical** | Mono; **0.1├óΓé¼ΓÇ£0.5 s** one-shot; sine or square beep 800├óΓé¼ΓÇ£1200 Hz |
| **Max size** | &lt; 150 KB |
| **Mix** | Clear at terminal; similar perceived loudness to one `keyboard` hit |
| **Search keywords** | `UI error beep`, `access denied`, `invalid input`, `negative beep`, `terminal error`, `retro computer beep` |
| **Anti-patterns** | Voice ├óΓé¼┼ôerror├óΓé¼┬¥, Windows critical stop, smoke alarm, long alarm loops |

**Trigger:** Rack error path (`ErrorSoundPath` / `ErrorBeepSound`).

---

## P2 optional (intake script only ├óΓé¼ΓÇ¥ not wired in C#)

| Slot | Note |
|------|------|
| `metal-hit` | Future damage impact |
| `smoke` | Overheat / failure |
| `explode` | Catastrophic rack failure ├óΓé¼ΓÇ¥ defer until gameplay needs it |

---

## Cross-job consistency (S-3 ├óΓé¼ΓÇ¥ hacker terminal parity)

| Topic | Recommendation |
|-------|----------------|
| **Separate addons** | `bitcoinmining` ├óΓÇáΓÇÖ `sounds/bitcoinminer/` ├é┬╖ `hackerjob` ├óΓÇáΓÇÖ `sounds/hacker-terminal/` (future) |
| **Shared family?** | **Same switch archetype, different mix identity** ├óΓé¼ΓÇ¥ both ├óΓé¼┼ôindustrial terminal├óΓé¼┬¥ but **not** the same WAV |
| **Bitcoin (amber)** | Warmer body, louder perceived click, slightly longer decay ├óΓé¼ΓÇ¥ HASHD / mining ops |
| **Hacker (green phosphor)** | Brighter, tighter, shorter transient ├óΓé¼ΓÇ¥ covert ops / scan UI |
| **Ship rule** | If owner records once, record **two EQ passes** from one session (amber low-pass gentle vs hacker brighter) rather than sharing one file across addons |

Red decides whether to reuse a **recording session**, never a **shipped file** across packages without doctrine review.

---

## Relative loudness cheat sheet

```text
hub-startup     ├óΓÇô╦å├óΓÇô╦å├óΓÇô╦å├óΓÇô╦å├óΓÇô╦å├óΓÇô╦å├óΓÇô╦å├óΓÇô╦å├óΓÇô╦å├óΓÇô╦å├óΓÇô╦å├óΓÇô╦å  (peak one-shot)
keyboard        ├óΓÇô╦å├óΓÇô╦å├óΓÇô╦å├óΓÇô╦å├óΓÇô╦å├óΓÇô╦å├óΓÇô╦å├óΓÇô╦å├óΓÇô╦å├óΓÇô╦å    (RP-audible ├óΓé¼ΓÇ¥ owner ask)
error           ├óΓÇô╦å├óΓÇô╦å├óΓÇô╦å├óΓÇô╦å├óΓÇô╦å├óΓÇô╦å├óΓÇô╦å├óΓÇô╦å├óΓÇô╦å
glitch          ├óΓÇô╦å├óΓÇô╦å├óΓÇô╦å├óΓÇô╦å├óΓÇô╦å├óΓÇô╦å├óΓÇô╦å├óΓÇô╦å
hub-fan-down    ├óΓÇô╦å├óΓÇô╦å├óΓÇô╦å├óΓÇô╦å├óΓÇô╦å├óΓÇô╦å├óΓÇô╦å
hub-startup     ├óΓÇô╦å├óΓÇô╦å├óΓÇô╦å├óΓÇô╦å├óΓÇô╦å├óΓÇô╦å├óΓÇô╦å       (tail)
server-hum      ├óΓÇô╦å├óΓÇô╦å├óΓÇô╦å├óΓÇô╦å├óΓÇô╦å         (loop bed, ramps 8s)
hub-fan-loop    ├óΓÇô╦å├óΓÇô╦å├óΓÇô╦å├óΓÇô╦å          (loop bed)
```
