# RECON BRIEF — Menu topology audit

**Read-only.** Sensors named per claim. `develop` @ `5177b98`.
The Servers page is the acceptance bar; everything is measured against it.

---

## 0. Verdict first

Six panes. **One conforms.** No ghost pages. The cheapest conformance win is Logs; the most
expensive is Overview, and the reason is structural, not cosmetic.

---

## 1. Topology

Sensor: `grep -n '<div class="pane '` and the `OpsTab` enum / `_tabs` array.

```
OpsTab { Overview, Wallet, Transfers, Racks, Logs, Settings }     razor:1008
_tabs  { Overview, Racks, Wallet, Transfers, Logs, Settings }     razor:1097
```

**Ghost-page check: CLEAN.** Six members, six routable, and the sidebar order matches
`_tabs` (Racks second). The `OpsTab.Upgrades` orphan and its icon/label arms died in Slice
3.5; `grep` for `OpsTab.Upgrades` returns nothing.

### Navigation edges

```
sidebar ──> Overview   (no sub-pages)
        ──> Servers ──> Home ──┬─> HubDetail        (1 click, back → Home)
        │                      ├─> TerminalDetail   (1 click, back → Home)
        │                      └─> RackChooser ──> RackDetail  (2 clicks, back → Chooser)
        ──> Wallet     (no sub-pages)
        ──> Transfers  (no sub-pages)
        ──> Logs       (no sub-pages)
        ──> Settings   (no sub-pages)
```

Servers is the only pane with internal navigation. Its state is a single explicit enum
(`ServersView`), so the five views cannot overlap. Every other pane is a flat leaf.

**Separate surface, not in this panel:** `LpBitcoinTerminalPanel.razor` (the in-world
terminal) and `hackerjob/HackerTerminal.razor`. Both render bitcoin state and neither is
reachable from this menu. They are outside the Entity Detail Contract entirely.

---

## 2. Conformance against the Servers bar

Sensor: count of `entity-chip-row`, `server-stat-plate`, `settings-pill`/`overview-snapshot`,
`lp-ui-panel-title` inside each pane's line range.

| Pane | chip-row | stat-plate | foreign pill | Contract tenant? |
|---|---|---|---|---|
| `racks` (Servers) | **5** | **3** | 0 | **yes — the bar** |
| `overview` | 0 | 0 | **15** | no |
| `wallet` | 0 | 0 | 0 | no |
| `transfers` | 0 | 0 | 0 | no |
| `logs-pane` | 0 | 0 | 0 | no |
| `settings-pane` | 0 | 0 | **2** | no |

Three distinct chip grammars coexist:

- `entity-chip` — Servers. The standard. Law-13 state colours (`green`/`gold`/`red`/`dim`).
- `settings-pill` — Settings (2 uses). Own colour states (`warn`/`off`).
- `overview-snapshot-*` — Overview (15 uses). Its own value/sub/label triple, with an
  `on`/`off` modifier instead of chips.

---

## 3. Ranked conformance list — cheapest first

Cost is cited from code, not guessed.

### 1. Logs — CHEAPEST
*Why cheap:* zero foreign grammar to unpick (0 pills, 0 chips). It is a titled scroll region
plus rows. Adding an `entity-chip-row` for feed state (`N ENTRIES` / `CLEARED`) and moving
the count out of `HubLogsCountLabel()` prose is additive. `LpBitcoinScrollRegionFactory` and
`LifePunchUiScrollPolicy` already own the scroll contract, and `DevScrollLogs` + `DevLogsProbe`
already exist as a proof surface.
*Risk:* the logs scroll anchor (`MaintainLogsScrollAnchor`, razor:2876) is load-bearing —
prepend-compensation maths. Do not reflow the row height without re-gating the anchor.

### 2. Settings
*Why cheap:* only 2 `settings-pill` uses, both status readouts
(`TerminalSettingsStatusLabel()`, `HubLogsCountLabel()`). Both map 1:1 onto `entity-chip`
with a state class. The switch/row primitives stay.
*Why not cheapest:* the terminal link toggle mutates world state
(`ToggleTerminalLink` → `LinkNearbyTerminal`/`UnlinkTerminal`), so it needs a real gate, not
a screenshot.

### 3. Wallet
*Why moderate:* 0 foreign pills, so nothing to unpick — but it has **zero Law-13 colour
spans** (see the Wallet brief) and a live text-entry transact half that the Entity Detail
Contract has no primitive for. `TextEntry` bind values are deliberately excluded from
`BuildHash`, so a naive tenant conversion would break the input.
*Blocked by:* the suspected cash-out TOCTOU and the 4 dp sensor vs 6/8 dp render. Fix the
invariant before the paint.

### 4. Transfers
*Why moderate-expensive:* same colour-grammar gap as Wallet, plus **no dev entry point
exists** (`DevOpenWalletTab` has no transfers sibling), so there is currently no way to gate
it at all. Building the proof surface is a prerequisite, not part of the work.

### 5. Overview — MOST EXPENSIVE
*Why expensive:* 15 `overview-snapshot-*` elements form a parallel design system — its own
label/value/sub triple with `on`/`off` state, not chips. Conforming it is not a restyle; it
is a rewrite of the pane's vocabulary. It is also the only pane that aggregates across
entities (`linkedRackCount`, setup-complete rollup), which puts it squarely under
*a card must not contradict the page it leads to* — the same trap the GPU RACKS aggregate
fell into. Its `Setup` tile already asserts a rollup (`HubIsPowered() && HasLinkedTerminal()
&& linkedRackCount > 0`, razor:169) that no page corroborates.

---

## 4. Cross-panel observations

- **Precision drift.** The hub wallet is rendered at four different precisions across panes
  (F4 header, F4 overview, F6 wallet/transfers, 8 dp Hub detail) while the refresh sensor
  resolves at 4 dp. Any topology work that moves a wallet readout between panes changes its
  precision silently. Detail in the Wallet brief.
- **Two terminals.** `LpBitcoinTerminalPanel.razor` (in-world) and the `Terminal` tenant page
  inside Servers now both describe "the terminal". The tenant page is all-PLANNED and
  describes upgrades; the in-world panel is the live command surface. Nothing links them.
  Worth a naming ruling before either is restyled.
- **`DevTrackRowProbe` generalises.** It reports L/R/W for any classed panel. Pointing it at
  other panes gives measured conformance instead of eyeballed conformance, for free.

---

## 5. Gaps

- I did not screenshot Transfers (no dev entry point) or Logs/Settings this pass.
- `LpBitcoinTerminalPanel.razor` topology is named but not mapped; it is a second panel with
  its own tab structure and deserves its own audit before it is called conforming or not.
- "Dead-but-routable" was checked at the `OpsTab` level only. Individual buttons within
  panes were not swept for dead handlers.
