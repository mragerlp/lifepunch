# DAILY CORNERMAN LONG UNATTENDED RUN — Corrected Rules (2026-06-25)

This is the repeatable process going forward.

## On Cornerman (start of run)

```powershell
cd C:\Users\jared\Projects\LIFEPUNCH
git fetch
git pull --rebase
```

Load Green Deep:

```powershell
lms get qwen/qwen3.6-27b@q6_k --gguf
lms ls --llm --detailed
lms load <EXACT_KEY> --gpu max --context-length 32768
lms ps
```

Set generation defaults in the model profile:
- Thinking: ON
- Preserve Thinking: OFF
- Temperature: 0.6
- Top P: 0.95
- Top K: 20

## Report Delivery Rules (strict)

- Use template: `lifepunch/docs/handoff/LIFEPUNCH_AI_REPORT_TEMPLATE.md`

- Save every completed report to:
  - `C:\LIFEPUNCH\Reports\`   ← Authoritative location (this is what you read from)
  - `C:\lifepunch\cornerman\outbox\`   ← Mirror

- **Never** write reports into the monorepo clone (`lifepunch/docs/reports/`) on this machine.
- **Do not** commit or push reports from Green.

- Filename: `YYYY-MM-DD_HHMM_ShortTitle.md`

## Execution Order

Run directives **sequentially** with a fresh model session/context for each major directive:

A. `lifepunch/addons/docs/briefs/CORNerman_LPADONS_FULL_ECOSYSTEM_PREP_UNTIL_1130PM.md`

B. `lifepunch/addons/docs/briefs/CORNerman_LPWEAPONS_PLATFORM_AUDIT_PREP.md`

C. `lifepunch/addons/docs/briefs/CORNerman_LIFEPUNCHULX_AND_SHARED_PATTERNS_PREP.md`

Do not interleave them inside one long context.

## End of Run Signal

```
OK cornerman lpaddons-long-run complete @<time>
head=<commit>
profile=Green Deep (Qwen3.6-27B Q6_K)
outputs=<count>
eyes=covered
no-code
no-commit
```

## When Bloodwave Returns (RDP workflow)

1. RDP into Cornerman.
2. Open `C:\LIFEPUNCH\Reports\`.
3. Copy the latest report(s).
4. Paste into ChatGPT / Architect for review.

After review, Red (on VENGEANCE) will copy only the approved reports into the repo and commit with consent.

## Repeatability

Update the list of active directives in the daily paste each time the focus changes. The delivery rules above stay the same.