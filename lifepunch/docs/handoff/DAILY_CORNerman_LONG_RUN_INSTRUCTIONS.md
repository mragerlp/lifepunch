# DAILY CORNERMAN LONG UNATTENDED RUN — Repeatable Instructions

Use this process every day you want Cornerman to run long prep (e.g. the next 3 days).

## On VENGEANCE (before logging off)

1. Make sure your latest work is committed and pushed.
2. Send the "FINAL_VENGEANCE_LOGOFF_PASTE_FOR_CORNerman" (or a fresh version) to Cornerman.
3. Shut down VENGEANCE cleanly when ready.

## On Cornerman (start of long run)

Run these steps in order:

```powershell
cd C:\Users\jared\Projects\lifepunchdxrp
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

Set generation defaults in LM Studio for the model (or send per request):
- Thinking: ON
- Preserve Thinking: OFF
- Temperature: 0.6
- Top P: 0.95
- Top K: 20

## Work to Run

Point Cornerman at the current active directive(s). As of 2026-06-25 these are the main ones:

- `lifepunch/addons/docs/briefs/CORNerman_LPADONS_FULL_ECOSYSTEM_PREP_UNTIL_1130PM.md` (main long directive)
- `lifepunch/addons/docs/briefs/CORNerman_LPWEAPONS_PLATFORM_AUDIT_PREP.md`
- `lifepunch/addons/docs/briefs/CORNerman_LIFEPUNCHULX_AND_SHARED_PATTERNS_PREP.md`

## Report Rules (always)

- Use template: `lifepunch/docs/handoff/LIFEPUNCH_AI_REPORT_TEMPLATE.md`
- Save to both:
  - `lifepunch/docs/reports/`
  - `C:\LIFEPUNCH\Reports\`
- Filename: `YYYY-MM-DD_HHMM_ShortTitle.md`

## End of Run Signal

When finished or at cutoff time:

```
OK cornerman [short-name]-complete @<time>
head=<commit>
profile=Green Deep (Qwen3.6-27B Q6_K)
outputs=<count>
eyes=covered
no-code
no-commit
```

## When You Return (next day)

1. RDP into VENGEANCE.
2. Open a terminal and run:
   ```powershell
   cd C:\Users\jared\Projects\lifepunchdxrp
   git pull --rebase
   ```
3. Go to `lifepunch/docs/reports/`
4. Open the newest report(s).
5. Copy the content.
6. Paste into ChatGPT with:
   "Analyze this Green report against the LIFEPUNCH architecture."

This process is designed to be repeatable with minimal friction.

Update the "current active directives" list in the daily paste each time you change the focus.