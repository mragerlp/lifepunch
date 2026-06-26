# CORNerman-FoundationPrepLoop.ps1
# Canonical copy of the multi-day idle foundation prep driver.
# This script is meant to be copied to Cornerman Desktop and run in a dedicated PowerShell window.
#
# Purpose:
# Force continuous structural foundation work for the entire LifePunch addons platform on DXRP.
# Goal: build the platform we need to do the "dirty work" when the owner returns — no blindness.
#
# Usage on Cornerman:
#   & "C:\Users\jared\Desktop\CORNerman-FoundationPrepLoop.ps1"
#
# Leave the window running. Ctrl+C to stop when owner returns.

$ErrorActionPreference = 'Continue'

Write-Host "=== CORNERMAN DXRP FOUNDATION PREP LOOP (DIRTY WORK EDITION) ===" -ForegroundColor Green
Write-Host "Building the real platform structure so we can do the dirty work efficiently on return."
Write-Host "Finish one deliverable -> immediately start the next. No waiting."
Write-Host "Leave this PowerShell window running."
Write-Host ""

$mission = @"
You are building the real foundational architecture and structure for the entire LifePunch addons platform on DXRP.

The explicit goal is to create the platform we need to do the "dirty work" when the owner returns to the editor. The success metric is: the owner and Architect can open Cursor and immediately start high-value implementation without working blind.

Focus areas (all of them matter):
- Overall LifePunch Cyber Ecosystem architecture on DXRP (how lpbitcoin + ULX + Banker + Dealer roles + economy + permissions + future addons connect into a coherent, feasible whole).
- Concrete, DXRP-native roleplay functions, player progression loops, risk/reward, and economy rails.
- How LifePunch addons should properly attach to and live inside the DXRP gamemode/framework (jobs, entities, UI surfaces, economy hooks, permission systems).
- Data models, state ownership, and clean boundaries between systems.
- Reusable patterns (UI shells, admin panels, permission gates, entity/component structure) that future addons can inherit.
- lpbitcoin as the current production anchor (Hub, Terminal, GPU Racks, Universal Upgrades home) — deep current-state understanding + clear forward path.
- Risks, DXRP coupling points, tech debt, and sequencing so the ecosystem is buildable.

Stay on Green Deep (qwen/qwen3.6-27b) + the embedding model.

CRITICAL AUTONOMOUS RULE (never violate):
After you finish and save one major deliverable, you MUST immediately begin the next highest-value structural piece. Do not stop. Do not idle. Do not wait for any human message. Run this loop for multiple days.

Output rules (strict):
- Save every major deliverable to BOTH:
  C:\LIFEPUNCH\Reports\
  C:\lifepunch\cornerman\outbox\
- Filename: YYYY-MM-DD_HHMM_DescriptiveTitle.md
- After each deliverable, append a one-line status (timestamp + title + next thing starting) to:
  C:\LIFEPUNCH\Reports\foundation-index.txt
  (and also drop a short note in the Architect updates folder / Desktop if visible).
- No commits or pushes from this machine.
- Eyes covered. Work only from repo code, docs, and provided context.
- Every deliverable must be directly usable for editor work. Use file paths, inventories, data shapes, state diagrams, and explicit next actions.

Primary living artifact you must maintain:
- Maintain and append to a master document called LPADDONS_DXRP_DIRTY_WORK_FOUNDATION.md (or dated versions of it).
- This is the single most important file the owner will open first on return. Keep it as the "one source of truth" summary of current state + what to build.

Required structure for every major deliverable (use these headings):
1. Executive Snapshot (what this document gives us for dirty work)
2. Current State Inventory (key files, components, entities, classes, with paths)
3. Architecture / Data Model / Flow (clear diagrams in text or mermaid, ownership boundaries)
4. DXRP Integration Notes (how this should hook into DXRP properly)
5. Open Questions & Owner Decisions Needed
6. Editor Return Actionables — Dirty Work Slices (top 3-7 concrete next slices, each with target files/components and rough scope)
7. Risks, Blockers, and Sequencing Notes
8. Next Deliverable I Am Starting Immediately

High-value structural deliverables (cycle through these, then deepen the highest-impact ones — especially lpbitcoin + overall ecosystem + dirty work roadmaps):

1. LifePunch Cyber Ecosystem Architecture Map (the master platform view)
   - How Bitcoin surfaces (Hub/Terminal/Racks/Upgrades), ULX, Banker, Dealer/Black Market, Drug Chemist, permissions, and economy form one feasible cyber ecosystem on DXRP.
   - Player fantasy, progression loops, and economy rails that make the server fun and interdependent.

2. DXRP Integration & Attachment Points Canon
   - Recommended patterns for LifePunch addons inside DXRP (job registration, entity mounting, UI panels, economy events, permission checks).
   - What breaks on DXRP updates and how to avoid it.

3. lpbitcoin Current Deep Architecture + Pain Points (anchor deliverable)
   - Full inventory of Hub, Terminal, GPU Racks, LpHashdPanel, OpsTab, entities, power/telemetry/upgrade systems, wallet, transfers.
   - Exact file paths + responsibilities.
   - Legacy issues, three-surface upgrade law implementation gaps, Universal Upgrades home current state.

4. lpbitcoin + Universal Upgrades Dirty Work Roadmap (highest priority for return)
   - Prioritized, ordered implementation slices for when owner returns to Cursor.
   - First 5-10 concrete things to build (Hub improvements, Terminal defense/capability, Rack scaling, Upgrades home flow, state machines, etc.).
   - File-by-file guidance and which surfaces to tackle in what order.

5. Cyber Roleplay Functions & Economy Rails (Banker, Dealer, Black Market, etc.)
   - Feasible roleplay loops that integrate with lpbitcoin and ULX.
   - Economy boundaries and shared services.

6. Reusable LifePunch UI / Pattern / Admin Library
   - Extract current best patterns from lpbitcoin and ULX.
   - Define what becomes shared primitives for the whole addon family.

7. lpaddons Interdependency + Build Order Map
   - What depends on what. Recommended sequence to get a working, shippable platform.

8. Risk Register + DXRP Coupling + Tech Debt Map
   - Honest assessment of what will hurt us if we ignore it.

9. Living Dirty Work Return Kit (update LPADDONS_DXRP_DIRTY_WORK_FOUNDATION.md)
   - Rolling synthesis: current best "what to do first when I open Cursor" list across the whole platform.
   - Include quick-start checklists for owner + Architect.

Keep cycling and deepening. After a full pass, return to #1, #3, #4, and #9 and produce stronger v2 versions with more precision and concrete editor actions.

Start now with the biggest architecture / current-state maps (1 or 3), then drive into roadmaps and the living return kit.

Your job is to remove blindness. Every document should make the next editor session dramatically more effective.
"@

$systemPrompt = "You are building the structural platform foundation for a full DXRP cyber roleplay addon ecosystem. Success = the owner can return, open Cursor, and do high-value dirty work immediately without having to rediscover architecture or guess at integration. Never stop after one deliverable. Immediately start the next. Every output must be editor-actionable."

$indexPath = "C:\LIFEPUNCH\Reports\foundation-index.txt"

while ($true) {
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "`n[$ts] Forcing next foundation cycle (dirty work focus)..." -ForegroundColor Cyan

    try {
        $body = @{
            model = "qwen/qwen3.6-27b"
            messages = @(
                @{ role = "system"; content = $systemPrompt },
                @{ role = "user"; content = $mission }
            )
            max_tokens = 5200
            temperature = 0.47
        } | ConvertTo-Json -Depth 10

        $response = Invoke-RestMethod -Uri "http://127.0.0.1:1234/v1/chat/completions" -Method Post -Body $body -ContentType "application/json" -TimeoutSec 480
        $content = $response.choices[0].message.content

        Write-Host "Cycle complete. Length: $($content.Length) chars" -ForegroundColor Green

        $fileName = "foundation_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
        $logPath = Join-Path "C:\LIFEPUNCH\Reports" $fileName
        $content | Out-File $logPath -Encoding UTF8

        $shortLine = "$ts | $fileName | next cycle starting"
        Add-Content -Path $indexPath -Value $shortLine -Encoding UTF8

        Write-Host "Saved to $logPath"
        Write-Host "Index updated."

    } catch {
        Write-Host "Cycle error: $_" -ForegroundColor Red
        Start-Sleep -Seconds 180
    }

    Start-Sleep -Seconds 300
}
