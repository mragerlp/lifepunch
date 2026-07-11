# PACKET TRANSPORT LAW (CVL)

Status: CANON — ratified 2026-07-08 (rides the next docs pass; law text per Bloodwave relay).

Red→Green delivery is the **shared inbox ONLY** (`\\GREEN\cornerman\inbox`, mapped `G:` on
Red): plain file copy + `.sha256` sidecar for binaries; the worker verifies on pickup.

**Source payloads are never shipped as archives** — they are **git pins** (Green's read-only
`lifepunchdxrp` mirror, fetch+checkout of the named commit); the packet states `repo@commit`
and paths.

**Ad-hoc transports are prohibited** — chunked base64, inline SSH file writes, bespoke
scripts. If the share is down, **fixing the share IS the task**.

**Trigger law unchanged:** packets fire on Green, by Bloodwave, never remotely.

## Why (recorded 2026-07-08)

The chunked-base64 SSH transport produced a zero-byte decode on a live Packet D transfer
(remote hash `E3B0C442…` = SHA256 of empty input). Plain `scp`/`sftp` to Green fail with
"Received message too long" — Green's sshd routes **every** session, including SFTP
subsystem requests, through a PowerShell wrapper that injects a pseudo-banner into the
stream (also the cause of quote-mangling on `ssh` exec). The shared inbox bypasses SSH
entirely and ends the class of failure.

## Setup (one-time, on-box)

1. **Green:** share `C:\lifepunch\cornerman\inbox` over SMB → **Red:** map as `G:`.
2. **Green:** clean read-only clone of the DXRP mirror for git-pin payloads (separate from
   the parked `dxrp-public` working clone — that one stays untouched).

Related: `CORNERMAN_FOR_AGENTS.md` (offload pattern) · `CORNERMAN_HEADLESS_DROP_WORKER.md`
(worker internals) · `GREEN_EXECUTION_MODEL.md` (sync law).

## Return lane (addendum 2026-07-11)

Return lane = `\\10.10.10.2\CornermanOutbox` (tasks→inbox, results/notes→outbox, by design);
corner-note filenames use underscores (`CORNER_NOTE_...`); `G:` mapped-drive reads unreliable
— UNC copy to `C:\` remains the retrieval pattern.
