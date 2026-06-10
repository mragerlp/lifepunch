<#
.SYNOPSIS
  One paste for Odysseus install round - Blue installs reader, Green stays feed-clean, Red runs session-sync.

.EXAMPLE
  powershell -File Get-CvlOdysseusRoundPaste.ps1 -CopyToClipboard
#>
[CmdletBinding()]
param(
    [string] $PingNote = 'cvl-odysseus-install',
    [switch] $CopyToClipboard
)

$paste = @"
================================================================
LIFEPUNCH CVL - ODYSSEUS ROUND (G + B) | ONE PASTE | RED'S ARM
PING: $PingNote
Goal: Odysseus on Blue reads tier-tagged hub memory - ONE final CVL answer (not Mr. Rager merging replies)
================================================================

YOU BOTH SEE THE FULL ROUND. Do your section only. No routine replies to VENGEANCE.
Exception only: BLOCKED <lane>: <reason>

WHEN BOTH LANES DONE -> Mr. Rager tells VENGEANCE: "both lanes done"
Red runs ONE ping:
  .\lifepunch\scripts\Invoke-CvlUniversal.ps1 -IngestToHub -Note "$PingNote"

--- RED (VENGEANCE - Mr. Rager, before or during Blue install) ---
  - Leave session-sync feeding hub (Start Day or):
      .\lifepunch\scripts\start-session-sync.ps1
  - Hub should have CVL tier lines (universal/vengeance/cornerman/lifepunchnet)

--- BLUE (lifepunchnet) - PRIMARY WORK ---
  1. RDP session on box (Administrator for elevated steps)
  2. cd C:\lifepunch\lifepunch-rdp-server && git pull --rebase
  3. Elevated:
       cd lifepunch\server\scripts
       powershell -ExecutionPolicy Bypass -File .\Install-Odysseus-Lifepunchnet.ps1
  4. If Ollama missing: winget install Ollama.Ollama - then re-run install script
  5. In Odysseus UI http://127.0.0.1:7000 :
       - Change admin password (from terminal)
       - Settings -> model API http://localhost:11434/v1
       - AUTH on, loopback only - never expose :7000 publicly
  6. Point context at hub (read odysseus-cvl-context.txt in C:\lifepunch\status\):
       - C:\lifepunch\session-hub\voice-session.ndjson
       - Optional RAG/imports: C:\lifepunch\session-hub\imports\
  7. After password set, optional logon task:
       powershell -ExecutionPolicy Bypass -File .\Register-Odysseus-LifepunchnetTask.ps1
  8. Run watchdog once so :9101 reports odysseus:
       powershell -ExecutionPolicy Bypass -File .\ServerHost-Watchdog.ps1

HARD RULES (Blue): no real email/API creds in Odysseus; agent has NO write-git creds; AGPL internal use only.

--- GREEN (Cornerman) ---
  - Stay token-clean (no hub Bearer on Green)
  - Confirm cornerman-rag voice stack present (Talk to Vengeance when voice needed)
  - Feed stays: PTT -> Whisper -> session-sync -> hub (Red bridge) - no tumble

OPTIONAL after Odysseus UI live:
  - Paste GET /tail?lines=50 hub JSON into Odysseus chat and ask: "CVL RGB state + blockers?"

Canonical: lifepunch/server/ODYSSEUS_LIFEPUNCHNET_START.md
================================================================
"@

Write-Output $paste

if ($CopyToClipboard) {
    try {
        Set-Clipboard -Value $paste
        Write-Host 'Copied to clipboard.' -ForegroundColor Green
    }
    catch { }
}

Write-Host ''
Write-Host "Ping id: $PingNote" -ForegroundColor Cyan
Write-Host 'Send this SAME paste to Cornerman and lifepunchnet when Mr. Rager confirms send time.' -ForegroundColor DarkGray
