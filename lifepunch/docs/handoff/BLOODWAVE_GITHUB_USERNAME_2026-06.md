# Bloodwave vs GitHub username — CVL pull brief (2026-06-15)

**Pushed from VENGEANCE.** All CVL nodes: pull monorepo before next session.

## Decision

- **Bloodwave** = public alias (Steam, Discord, in-game, GitHub **display name**)
- **`mragerlp`** = GitHub **username** — **keep** (do not rename to `bloodwave`)
- Canon: `lifepunch/docs/BLOODWAVE_ALIAS.md`

## Pull commands

### Cornerman (read-only monorepo clone)

```powershell
cd C:\Projects\lifepunch
git fetch
git pull --rebase origin main
```

Read-only deploy key cannot push — patch-handoff to VENGEANCE only if Cornerman authored commits.

### lifepunchnet (rdp-server lane)

Docs-only change; optional pull if you mirror monorepo for RAG:

```powershell
cd C:\lifepunch\lifepunch-rdp-server
git fetch
git pull --rebase
```

If lifepunchnet only tracks GitLab `lifepunch-rdp-server`, no action unless owner re-exports lane.

### VENGEANCE

Already pushed. Verify: `git log -1 --oneline` → `docs(bloodwave): record GitHub username decision`

## Agent confirm (one line)

> Pulled `<sha>`; Bloodwave = visible alias; GitHub username stays `mragerlp`.
