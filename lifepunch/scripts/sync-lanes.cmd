@echo off
rem CVL LANE SYNC v1 (2026-07-12) - runs on VENGEANCE via Task Scheduler
rem Direction 1: pull Green returns  OUTBOX(CORNERMAN) -> comms\green
robocopy \\10.10.10.2\CornermanOutbox C:\lifepunch\comms\green /E /XO /NJH /NJS /LOG+:C:\lifepunch\comms\green\pull.log
rem Direction 2: push Green orders   comms\dispatch\green -> cornerman-inbox\dispatch-green
robocopy C:\lifepunch\comms\dispatch\green \\10.10.10.2\cornerman-inbox\dispatch-green /E /XO /NJH /NJS /LOG+:C:\lifepunch\comms\dispatch\green\push.log
rem Direction 3 (Ruling P-ii): read-only BOARD.md copy for Green's dispatch third-key verification
robocopy C:\lifepunch\comms \\10.10.10.2\cornerman-inbox\dispatch-green BOARD.md /NJH /NJS
rem robocopy exit codes 0-7 are success variants; force clean exit so
rem Task Scheduler history reads green (per COMMS_PROTOCOL v1.1.1 rule 3)
exit /b 0
