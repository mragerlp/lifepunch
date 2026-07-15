# KEPLER REMOTE EXECUTION DOCTRINE

**Ratified:** 2026-07-14, Bloodwave — Option C (agent-managed SSH) ruled over A (WSL) and B (wait for
Kepler Windows support).
**Graduated from:** `fable\0080` (CANON DRAFT), Fable #7. **Supersedes `fable\0077`, which does NOT
graduate.**
**Class:** DOCTRINE. Landed to `docs/cvl/` per the draft's own instruction (dispatch: canon-sweep3).

> **KEY LEDGER ENTRY OWED** (§3): the `kepler_cornerman` ed25519 key is not yet censused in
> `KEY_LEDGER.md`. The draft flagged this "at next canon commit"; it is **not discharged by this landing**
> and remains owed. Rule C-1 stands — no seat reads the private key file.

---

## §1 OPERATING SHAPE

Kepler runs on VENGEANCE. All tasks launch locally. Heavy compute is offloaded to CORNERMAN by the agent
inside the task via SSH.

```
VENGEANCE (control plane)          CORNERMAN (compute target)
┌─────────────────────┐            ┌──────────────────────┐
│ Kepler UI + tasks   │            │                      │
│ ├─ Worktree (local) │   SSH key  │ git 2.54.0           │
│ │  └─ Agent ────────┼──────────►│ SDK 10.0.301         │
│ │     session       │  10.10.10  │ pwsh 7.6.3           │
│ │                   │◄──────────┤ opencode 1.17.20     │
│ ├─ s&box editor     │            │                      │
│ │  ├─ native :7269  │            │ C:\Kepler\Worktrees  │
│ │  ├─ chomnr :9090  │            │ C:\Kepler\Repos      │
│ │  └─ bridge IPC    │            │ C:\Kepler\comms-mirror│
│ └─ C:\lifepunch\    │  robocopy  │   (read-only local)  │
│    comms\ (source) ─┼──PT10M───►│                      │
└─────────────────────┘            └──────────────────────┘
```

## §2 WHY NOT KEPLER-NATIVE REMOTE

Kepler's remote task daemon (`~/.kepler-server`) requires a Linux target. CORNERMAN is bare Windows.
Installing WSL adds a permanent dependency layer for no proven benefit. Option C (agent-managed SSH) was
ruled by Bloodwave 2026-07-14 over options A (WSL) and B (wait for Kepler Windows support).

`fable\0077` DOES NOT GRADUATE. This doctrine supersedes it.

## §3 SSH INFRASTRUCTURE

| Item | Value |
|------|-------|
| Key | `C:\Users\jared\.ssh\kepler_cornerman` (ed25519) |
| Target | `jared@10.10.10.2` (direct link, not LAN) |
| Auth | `administrators_authorized_keys` on CORNERMAN |
| ACL | Administrators:F + SYSTEM:F only (sshd ignores others) |
| Firewall | OpenSSH-Server-In-TCP, both 192.168.1.0/24 + 10.10.10.0/24 |
| Adapter profiles | All Private (including the direct-link adapter) |

No seat ever reads the private key file (rule C-1). The key exists for agent SSH sessions — empty
passphrase is intentional (automated, non-interactive use). Revocation = one line deleted from
`administrators_authorized_keys` on CORNERMAN.

**KEY LEDGER ENTRY OWED** (see header — not discharged by this landing).

## §4 WHEN TO SSH OUT

| Task class | Runs on | SSH to CORNERMAN? |
|------------|---------|-------------------|
| Code review (cold read) | VENGEANCE | NO — lightweight |
| Diff proposal | VENGEANCE | NO — lightweight |
| Advisory / design brief | VENGEANCE | NO — lightweight |
| Full-tree census / grep | VENGEANCE agent SSHs out | YES |
| C# build / dotnet test | VENGEANCE agent SSHs out | YES |
| Multi-file refactor | VENGEANCE agent SSHs out | YES |
| PowerShell script run | VENGEANCE agent SSHs out | YES |
| Editor-coupled (Razor/SCSS/scene/prefab) | VENGEANCE local | NEVER — bridges are localhost |

The relay template carries the routing: "SSH heavy work to `jared@10.10.10.2` via the `kepler_cornerman`
key" for compute-heavy tasks. Light tasks omit it.

## §5 AGENT SSH PATTERN

The agent shells out from its VENGEANCE session:

```
ssh -i C:\Users\jared\.ssh\kepler_cornerman jared@10.10.10.2 "<commands>"
```

For multi-command sessions:

```
ssh -i C:\Users\jared\.ssh\kepler_cornerman jared@10.10.10.2 "cd C:\Kepler\Worktrees\<task> && git clone ... && dotnet build ..."
```

Results return over the SSH session. The agent writes them into its local worktree on VENGEANCE and files
to `comms\` normally.

## §6 CORNERMAN PATH RULES

| Path | Purpose | Who touches |
|------|---------|-------------|
| `C:\Kepler\Worktrees` | SSH agent scratch | Agents via SSH |
| `C:\Kepler\Repositories` | SSH agent clones | Agents via SSH |
| `C:\Kepler\comms-mirror` | Read-only comms mirror | CVL-CommsSync writes; agents read locally |
| `C:\Projects\lifepunch` | Green's clean clone | GREEN ONLY — Kepler never touches |
| `CornermanOutbox` | Green's output | Green writes; CVL-LaneSync pulls |

## §7 COMMS MIRRORS (both healthy, both PT10M)

| Task | Direction | Path |
|------|-----------|------|
| CVL-LaneSync | CORNERMAN → VENGEANCE | `CornermanOutbox` → `comms\green` |
| CVL-CommsSync | VENGEANCE → CORNERMAN | `comms` → `\\10.10.10.2\Kepler\comms-mirror` |

Remote agents ground from `C:\Kepler\comms-mirror` as a LOCAL read. The Kepler SMB share
(`\\10.10.10.2\Kepler`) grants `jared` Change access for the push; Everyone Read for browse.

## §8 CONCURRENCY

Start at TWO concurrent CORNERMAN SSH sessions. Raise only after observing RAM/CPU/VRAM on CORNERMAN
(Qwen daily model is resident; cloud-agent SSH tasks compete for indexing + terminal; simultaneous Qwen
tasks compete for GPU memory).

## §9 LANE PRESETS (amended from `fable\0077`)

| Preset | Machine | Use |
|--------|---------|-----|
| RED-EDITOR-DRIVE | VENGEANCE local | UI, Razor/SCSS, prefab, scene, runtime proof. ONE writable editor task. |
| GREEN-CODE-DRIVE | VENGEANCE → SSH CORNERMAN | Bounded C# implementation, PowerShell, tests, docs, repo-wide refactors. No runtime claims. |
| GREEN-LOCAL-REVIEW | VENGEANCE → SSH CORNERMAN (Qwen) | Repository scans, consistency, file maps, first-pass review. Advisory read-only. |
| KEPLER-CODEX-REVIEW | VENGEANCE local | Diff, files, code reads. SSH only if compute-heavy. |

## §10 INVARIANTS (unchanged)

- One DRIVE per worktree.
- Kepler is a control plane, not a seat — holds no authority.
- Bloodwave retains GO, acceptance, merge, ship, canon.
- Authority follows the model, not the price.
- Transport Law: every arrow is Bloodwave copy-paste.
- Key Law: dedicated minimum-scope keys, no seat reads credential files.

---
FROM: Red (graduated from Fable #7 `fable\0080`)
