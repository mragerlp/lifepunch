# Cornerman — Visible Pocket start brief (no Cursor required)

**You are:** Tier-3 prep on Green · **VENGEANCE owns:** C#, DXRP editor, git push  
**Package:** `lifepunch.visiblepocket` — **not** llad MIS (study only)

---

## Sync first

```powershell
cd C:\Projects\lifepunch
git fetch origin
git reset --hard origin/main
```

Expect HEAD: `a5e4461` or newer (`feat(visiblepocket): …`).

Read inbox after VENGEANCE push:

- `C:\lifepunch\cornerman\inbox\CORNERMAN_VISIBLE_POCKET_START.md` (this file)
- `lifepunch/addons/docs/VISIBLE_POCKET_SPEC.md`
- `lifepunch/addons/docs/reference/DXRP_POCKET_DISCOVERY.md`

---

## Your lane (docs + study — no C# commits)

| # | Task | Output |
|---|------|--------|
| 1 | **Distill** `DXRP_POCKET_DISCOVERY.md` into 10-line summary in outbox | `cornerman/outbox/VISIBLE_POCKET_DXRP_SUMMARY.txt` |
| 2 | **llad UI study** (optional) — if package mounted, note grid/HUD patterns only | `cornerman/outbox/VISIBLE_POCKET_UI_NOTES.txt` |
| 3 | **Watch** VENGEANCE reply slot | `cornerman/outbox/to-cornerman-visible-pocket.txt` — fold blockers into spec § Architecture |
| 4 | **Do not** add `visiblepocket` code or `addons.json` ship rows | VENGEANCE only |

---

## What VENGEANCE is testing now

```text
lp_pocket_policy        # your slot tier vs DXRP global max
lp_pocket_apply_dev     # host dev: apply your tier to global max
```

Play-test: pocket a `pocket_item` prop until full; confirm bitminer **cannot** pocket (`lifepunch_nopocket`).

Full steps: `lifepunch/addons/Code/Addons/lifepunch/visiblepocket/docs/VISIBLE_POCKET_PLAYTEST.md`

---

## Push inbox refresh (VENGEANCE runs)

```powershell
powershell -File lifepunch\scripts\Push-CornermanVisiblePocketBrief.ps1
```

---

## When VENGEANCE fills reply slot

Copy `to-cornerman-visible-pocket.txt` findings into:

- `VISIBLE_POCKET_SPEC.md` § Architecture (if needed)
- `TECH_DEBT.md` POCKET-01 swap point

Ping owner: "OK cornerman visible-pocket @&lt;sha&gt;" one line.
