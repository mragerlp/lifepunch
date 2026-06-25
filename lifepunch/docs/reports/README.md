# LIFEPUNCH Reports — Cornerman Output

This folder contains standardized, high-signal reports produced by Cornerman (Green Tier-3).

## Workflow

1. Cornerman finishes a task or major section of work.
2. It writes a report using the exact template in:
   `lifepunch/docs/handoff/LIFEPUNCH_AI_REPORT_TEMPLATE.md`
3. Final report is saved here with the naming convention:
   `YYYY-MM-DD_HHMM_<Short-Title>.md`
   Example: `2026-06-25_1045_BitcoinHub_UniversalUpgrades.md`

4. When you RDP into VENGEANCE:
   - `git pull`
   - Open the newest file in this folder.
   - Copy the whole report.
   - Paste into ChatGPT with the prompt:
     "Analyze this Green report against the LIFEPUNCH architecture."

## Why this format

- Consistent structure for quick scanning on phone or RDP.
- Clear separation of Facts vs Ideas.
- Explicit "CHATGPT TASKS" delegation section.
- Self-scored confidence so you know immediately if it's actionable.
- Versioned in Git (no lost reports).

## For Cornerman

Always use the template. Never invent your own format.

When a report is complete, commit it with a message like:
"report: Bitcoin Hub - Universal Upgrades prep"

Do not mix implementation code changes with report commits.

## Phone-friendly access

If you want reports on your phone without RDP:
- Sync this folder (or a copy) via OneDrive / Dropbox to a phone-accessible location.
- Cornerman can also drop a timestamped copy to a local path like `C:\LIFEPUNCH\Reports\` that you sync.

## Current priority

All reports must follow the template starting 2026-06-25.