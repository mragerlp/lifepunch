# Instructions for Cornerman Long Run (until ~11:30 PM EST)

## 1. Pull the latest changes on Cornerman

```powershell
cd C:\Users\jared\Projects\LIFEPUNCH   # or wherever the clone lives
git fetch
git pull --rebase
```

Confirm you are on a clean descendant of at least commit `52ba8f3`.

## 2. Load the correct model — Green Deep

Use **Green Deep** (Qwen3.6-27B) for this entire long session.

Recommended LM Studio settings:

- Model: qwen/qwen3.6-27b
- Quantization: Q6_K_L (or highest stable Q6)
- Context: 32768
- Thinking: ON
- Preserve Thinking: OFF
- Temperature: 0.6
- Top P: 0.95
- Top K: 20
- GPU offload: maximum stable

Confirm with:
```powershell
lms ps
```

You should see the 27B model loaded as the heavy model.

## 3. Main directive for this run

Process this file as the primary task:

`lifepunch/addons/docs/briefs/CORNerman_LPADONS_FULL_ECOSYSTEM_PREP_UNTIL_1130PM.md`

This directive covers:
- lpbitcoin Phase 1 priority (Hub/Terminal/Rack overhaul pain points + GO SHELL follow-up)
- Full lpaddons scope: shared UI patterns, cyber ecosystem connections (banker, black market, drug dealer menu extensions, etc.)
- Prep so that when Bloodwave returns ~11:30 PM, there is a clean, structured path for Opus work

## 4. When you finish or hit ~11:30 PM

Send this exact signal:

OK cornerman lpaddons-full-ecosystem-prep complete @<time>
head=<current commit>
profile=Green Deep (Qwen3.6-27B)
outputs=<how many files you produced>
eyes=covered
no-code
no-commit

Then stop.

## 5. For Bloodwave when he returns (~11:30 PM)

See:
`lifepunch/docs/handoff/OPUS_JUMPSTART_1130PM_2026-06-25.md`

This packet + the artifacts you produce tonight should give a clear starting point instead of re-deriving context.

---

Run this with Green Deep. Treat the entire lpaddons project as the scope, with lpbitcoin Phase 1 as the hard priority. Make the prep high-leverage for when real Opus work starts tonight.