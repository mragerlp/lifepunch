# Desktop organization checkpoint — June 2026

**Git anchor:** `b35a6bf` and later on `github.com/mragerlp/lifepunch` `main`.  
**Bloodwave local workspace:** `%USERPROFILE%\Desktop\lifepunch` — **not** shared with CVL as source of truth.

---

## Two layers (do not confuse)

| Layer | Path | Who uses it | Role |
|-------|------|-------------|------|
| **Monorepo** | `C:\Users\jared\Projects\lifepunch` | VENGEANCE + agents | Law, WIP, git checkpoints |
| **Desktop org** | `Desktop\lifepunch` | Bloodwave only | Local filing + portal-ready upload copies |

CVL nodes (Cornerman, lifepunchnet, shottaWEB) **pull the monorepo**. They do **not** need the Desktop folder unless you explicitly copy something to them.

---

## Desktop layout

```text
Desktop\lifepunch\
├── README.md
├── CHECKPOINT.md          ← this file (local copy; canon in repo handoff doc)
└── addons\
    ├── publish\           ← portal-ready packages (DXRP upload shape)
    │   └── lifepunchulx\
    │       ├── UPLOAD_README.md
    │       ├── portal-fields.json
    │       ├── package-export.json
    │       ├── SYNC_FROM.txt
    │       └── upload\
    │           └── Code\Addons\lifepunch\lifepunchulx\   ← upload this to portal
    └── working\           ← in-progress (empty until you promote a slice)
        └── lifepunchbitcoin\
            └── README.txt
```

---

## Publish folder law

- **Refresh command:** `powershell -File lifepunch\scripts\Sync-DesktopPublishFolder.ps1 -Addon adminmenu`
- Runs `prepare-publish.ps1` (strips dev/TestBots/DevSpawn files), then mirrors to Desktop with **packageSlug** paths (`lifepunchulx`, not repo `adminmenu`).
- **Upload shape** matches DXRP game project: `Code/Addons/lifepunch/<slug>/` under `upload/`.
- **Code-only ULX:** no Assets tree required for v1.

---

## What to tell CVL (only if needed)

Paste or point teammates to:

1. `lifepunch/docs/AGENT_SYNC_BROADCAST.txt` — session sync + foundation
2. `lifepunch/docs/handoff/JUNE_2026_FOUNDATION_CHECKPOINT.md` — all-node pull brief
3. **This checkpoint addendum** (below) — desktop org is Bloodwave-local; git is shared

### CVL addendum (June 2026 — lifepunchulx ship lane)

| Topic | Message |
|-------|---------|
| **Pull** | `git pull --rebase` on `mragerlp/lifepunch` `main` |
| **ULX command** | `lifepunchulx` / `/lifepunchulx` only — `staffmenu` and `adminmenu` removed |
| **Portal identifier** | `lifepunchulx` (was `dxrpadminmenu`) |
| **Settings permission** | `lifepunchulx.settings.edit` |
| **Publish-ready** | `lifepunchulx` only — LifePunch servers; proprietary; not for resale |
| **Bitcoin** | `lifepunchbitcoin` — greenfield v2 in monorepo; **not** publish export until Ophion sign-off |
| **Desktop folder** | Bloodwave local org on VENGEANCE — **not** a CVL sync target |
| **DXRP editor ULX lane** | `Set-DxrpLifepunchUlxOnly.ps1` — only `lifepunchulx` mounted |

No CVL action required unless you are publishing ULX or pulling for addon work.

---

## Publish-ready now: lifepunchulx

| Field | Value |
|-------|-------|
| packageSlug | `lifepunchulx` |
| repo ident | `adminmenu` |
| s&box | `lifepunch.ulx` |
| dxrpAddonId | `019e9cfa-3141-723c-a430-1a0e256472eb` |
| dxrpAddonIdentifier | `lifepunchulx` |
| marketing version | 2.0.0 |

---

## Working lane: lifepunchbitcoin

- Monorepo: `bitcoinmining` — v1 archived to `reference-intake/`; v2 `Lp*` scaffold
- Desktop `working/lifepunchbitcoin/` stays empty until you ask for a fresh working slice copied in
- Do **not** portal-publish until Ophion visual pass sign-off

---

## Related repo docs

- `lifepunch/docs/GIT_CHECKPOINTS.md`
- `lifepunch/docs/PUBLISH_REPO_LANE.md`
- `lifepunchaddons/docs/PUBLISHING.md`
- `lifepunchaddons/docs/DXRP_ULX_ONLY_LANE.md`
- `lifepunch/scripts/Sync-DesktopPublishFolder.ps1`
