# BLOODWAVE BOOT - OPERATOR CHECKLIST

- [ ] Treat this repository copy as maintained truth.
- [ ] Keep a desktop copy.
- [ ] Canon home: `lifepunch/docs/cvl/boot/BLOODWAVE_BOOT.md`.
- [ ] Lane copy: `C:\lifepunch\comms\BLOODWAVE_BOOT.md`.

## Boot a new Fable (conductor window, expensive model)

- [ ] Paste exactly this into a fresh Claude chat:

      Boot from state. Read C:\lifepunch\comms\STATUS.json,
      C:\lifepunch\comms\BOARD.md (tail), C:\lifepunch\comms\fable\FABLE_STATE.md,
      and the last 3 files in C:\lifepunch\comms\fable\. Then read
      C:\lifepunch\comms\COMMS_PROTOCOL.md and C:\lifepunch\comms\STACK_ARCHITECTURE.md.
      Report BOOT-CLEAN with a one-paragraph board summary, or BOOT-FAULT
      naming what you could not read. Take no action until I reply.

## Boot a new Red (Claude Code terminal on VENGEANCE)

- [ ] Tell Red: `Read lifepunch/docs/cvl/boot/RED_BOOT.md in the repo and execute its checklist.`
- [ ] Require `BOOT-CLEAN` or `BOOT-FAULT`.
- [ ] Give Red no task until `BOOT-CLEAN`.

## Boot a new Codex (Codex chat window)

- [ ] Tell Codex: `Read lifepunch/docs/cvl/boot/CODEX_BOOT.md via C:\Users\jared\Projects\lifepunch\docs\cvl\boot\CODEX_BOOT.md and execute its checklist.`
- [ ] Require `BOOT-CLEAN` or `BOOT-FAULT`.

## Boot Green (CORNERMAN)

- [ ] Fire a packet via `New-CornermanTaskPacket.ps1`.
- [ ] Make STEP 0: read `GREEN_BOOT.md` from the inbox, assert R7 freshness, and report `BOOT-CLEAN` or `BOOT-FAULT` before the task body.

## Run the sync cycle (the only loop)

- [ ] 1. Receive Fable's pastes; fire one per seat window.
- [ ] 2. Receive each seat's one-line completion reply.
- [ ] 3. Tell Fable `comms ready`, adding seat states if useful.
- [ ] 4. Receive Fable's receipt manifest, grades, and next pastes.
- [ ] 5. Repeat.

## Hold both keys - never delegate or automate

- [ ] Merge to `main` or any protected branch.
- [ ] Publish, ship, or install a portal revision on Official.
- [ ] Ratify canon.
- [ ] Authorize destructive operations: deletes, resets, snapshot restores.
- [ ] Authorize DXRP upstream sync or re-pin.
- [ ] Authorize anything spending real money.

## If something feels off

- [ ] Weird seat: say `STOP. Report state. No mutations.`
- [ ] Lost Fable: say `Re-read FABLE_STATE.md and BOARD tail, then re-state the board before continuing.`
- [ ] Unreadable lane: fall back to paste and tell Fable the lane is degraded.
- [ ] When in doubt, do not merge, ship, or delete. Waiting is safe.
