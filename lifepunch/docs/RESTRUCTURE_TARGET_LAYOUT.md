# LIFEPUNCH™ — Target repo layout (end state)

**Status:** **LAW LOCKED** 2026-06-30 — implementation via Phase 4–6 migration.  
**Updated:** 2026-06-30  
**Read with:** `REPO_DOMAIN_MAP.md` · `RESTRUCTURE_ROADMAP.md` · `PACKAGE_STAGING_LAYOUT.md`

This doc reconciles the **DXRP-parity vision** (standalone publishable packages, clear business splits) with **LifePunch canon** (GitHub monorepo canonical, GitLab lane exports, no spurious new GitHub repos).

---

## 1. Business & platform folders (under `lifepunch/`)

**Target:** Obvious domains — **not** separate GitHub repos at repo root.

```text
github.com/mragerlp/lifepunch          ← canonical monorepo (always)
├── README.md                          ← boot → REPO_DOMAIN_MAP.md
├── .cursor/  scripts/  reference/
└── lifepunch/
    ├── website/          BUSINESS  → GitLab lifepunch-website (shottaWEB)
    ├── marketing/        BUSINESS  → GitLab lifepunch-foundation
    ├── legal/            BUSINESS  → GitLab lifepunch-foundation
    ├── branding/         BUSINESS  → GitLab lifepunch-foundation
    ├── discord/          PLATFORM  → GitLab lifepunch-rdp-server
    ├── server/           PLATFORM  → GitLab lifepunch-rdp-server
    ├── gamemode/ portal/ admin-panel/ …   (PLATFORM — see REPO_DOMAIN_MAP.md)
    └── addons/           PRODUCT   → GitLab lifepunch-addons
```

| Your list | Domain | GitLab lane | Notes |
|-----------|--------|-------------|-------|
| `website/` | BUSINESS | `lifepunch-website` | lifepunch.co worker + rules mirrors |
| `marketing/` | BUSINESS | `lifepunch-foundation` | YouTube/social copy — **not** website lane |
| `legal/` | BUSINESS | `lifepunch-foundation` | Trademark/IP — never split to separate GitHub repo |
| `discord/` | PLATFORM | `lifepunch-rdp-server` | Community ops docs — not “business/marketing” |
| `server/` | PLATFORM | `lifepunch-rdp-server` | Hosted DXRP server records + dxrp-host |
| `README.md` | — | `lifepunch-foundation` | Repo root entry point |

**Not doing:** `lifepunch-legal`, `lifepunch-community` as new GitHub repos — GitLab exports already provide focused clones.

**Phase status:** Documented in Phase 0–3 ✅. No folder moves required for this section.

---

## 2. Addon package parent path (HARD LAW — all `lp*` packages)

**Every shippable package** uses parent folder:

```text
lifepunchaddons/lp{product}/          # lpbitcoin, lphacker, lpbanker, lifepunchulx, …
```

Not `lifepunchaddons/packages/lp*/`. Not legacy `Code/.../repoIdent/` alone.

**Public names (lpbitcoin example):** `packageSlug` **`lifepunchbitcoin`** · s&box **`lifepunch.bitcoin`** · entity slugs **`bitcoinhub`**, **`hashdterminal`**, **`gpurack`**.

### End state (Phase 4 + 6)

Standalone s&box addon project **inside the monorepo**, publishable to DXRP portal and exportable to `lifepunch-published`:

```text
lifepunchaddons/lpbitcoin/
├── bitcoin.sbproj                              # Ident: lifepunch.bitcoin · ParentPackage: dxura.rp
├── bitcoin.slnx                                # Optional; mirror addons.slnx pattern
├── Code/
│   └── Addons/lifepunch/lpbitcoin/
│       ├── _shared/                            # Was bitcoinmining/ package-wide (wallet, economy, UI bridge)
│       │   ├── LpBitcoinWallet.cs
│       │   ├── LpBitcoinEconomy.cs
│       │   └── …
│       ├── bitcoinhub/code/components/         # LpBitcoinHubEntity.cs, LpBitcoinHubVisuals.cs, …
│       ├── hashdterminal/code/components/      # LpBitcoinTerminalEntity.cs, …
│       └── gpurack/code/components/            # LpBitcoinRackEntity.cs, …
│   └── lpbitcoin.csproj                        # Compiles package only (Phase 6)
├── Assets/
│   └── addons/lifepunch/lpbitcoin/
│       ├── bitcoinhub/assets/…
│       ├── hashdterminal/assets/…
│       └── gpurack/assets/…
└── docs/
    ├── BITCOINMINING_POLISH_CHECKLIST.md
    └── …
```

Same pattern for **`lphacker/`**, **`lpbanker/`**, etc. when promoted from quarantine.

### Correction vs flat “Copilot sketch”

Your sketch listed `LpBitcoinHubEntity.cs` directly under `Addons/lifepunch/lpbitcoin/`. **Keep entity slots** per `PACKAGE_STAGING_LAYOUT.md`:

- **Folder name = entity slug** (`bitcoinhub/`, not flat hub files at package root).
- **Shared** cross-entity code → `_shared/` (or `code/shared/`), not a separate top-level `System/` unless we adopt Facepunch-style `Sandbox.System` — today LifePunch uses `Code/Addons/lifepunch/…` only.

`System/LpBitcoinSystem.cs` — **only if** we introduce a dedicated game system type; today logic lives in components + static helpers in `bitcoinmining/`. Migration maps files to `_shared/` first; system extraction is optional later.

---

## 3. Today vs target (gap)

| Area | Today | Target |
|------|-------|--------|
| Package root | Single `lifepunchaddons/addons.sbproj` + split Code/Assets trees | **`lifepunchaddons/lpbitcoin/`** full package root + `bitcoin.sbproj` |
| Docs | Split `bitcoinmining/docs/` + entity NAV | `lifepunchaddons/lpbitcoin/docs/` |

---

## 4. Migration slices (do in order)

### Phase 4a — Code consolidation (monolithic `addons.sbproj` still)

1. `git mv` `bitcoinmining/*.cs` → `lpbitcoin/_shared/` (or per-entity where clearly owned)
2. Update namespaces only if required (prefer minimal diff)
3. Update `addons.csproj` includes / removes
4. Update sync + publish scripts, `addons.json` primaryReference paths
5. `validate-layout.ps1` + flatgrass smoke

### Phase 4b — Retire `bitcoinmining` ident

1. `portfolio.json` — remove `bitcoinmining`; active = `lpbitcoin` package row
2. Remove empty `Code/.../bitcoinmining/` tree
3. Fix validator paths (`primaryReference` → `addons/lifepunch/lpbitcoin/...`)

### Phase 6 — Extract `bitcoin.sbproj`

1. Create `lifepunchaddons/lpbitcoin/bitcoin.sbproj` from `addons.sbproj` + `modeldoc.sbproj` patterns
2. Point DXRP editor Bitcoin-only lane at new project
3. Monolithic `addons.sbproj` retains `adminmenu` (+ dev tools) until next package extracts

**Do not** combine 4a + 6 in one PR.

---

## 5. What stays in monorepo `lifepunchaddons/` after Phase 6

```text
lifepunchaddons/
├── addons.sbproj              # Dev umbrella: adminmenu + _dev until ULX extracted
├── lpbitcoin/                 # lifepunch.bitcoin — standalone (Phase 6)
├── lifepunchulx/              # future Phase 6 sibling (from adminmenu)
├── config/                    # addons.json, packages.json, portfolio.json (registry)
└── …                          # transitional Code/Assets trees until Phase 4 completes
```

Registry JSON stays at **`lifepunchaddons/config/`** — not duplicated inside each package.

---

## 6. Owner GO lines

```text
GO Phase 4a — plan-only lpbitcoin code consolidation (list every file + script ref)
GO Phase 4a — implement lpbitcoin _shared migration (one commit, git mv only)
GO Phase 6 — extract bitcoin.sbproj (after 4b + validator green)
```

---

## Related

- `RESTRUCTURE_ROADMAP.md` — phase gates
- `CONFIG_SOURCE_OF_TRUTH.md` — which JSON updates on migration
- `_QUARANTINE_INDEX.md` — do not touch quarantined idents during lpbitcoin migration
