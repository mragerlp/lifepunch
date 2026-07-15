# BM-S5A — dealer storefront shell-slot specification

**Issue:** #150 · **Parent:** #144 · **Phase:** A (documentation only)
**Status:** implementation-gated on #135 / PR #143 merge; prices and purchase behavior gated on BM-S4
**Scope:** Black Market Dealer storefront requirements for the ruled `LpMenuShell` contract

## 1. Purpose and governing contracts

The dealer storefront is a future consumer of the shared `LpMenuShell`; it is not a new shell.
Phase B must provide exactly the seven ruled slots from PR #143:
`Mark`, `Wordmark`, `TopBarControls`, `NavItems`, `DoorCards`, `SnapshotStats`, and `QuickButtons`,
plus the separately ruled `AccentColor` parameter. Non-dashboard route bodies use the inherited
`Sandbox.UI.Panel.ChildContent` aperture and do not add an eighth slot.

This specification is grounded on:

- `lifepunch/docs/UNIVERSAL_MENU_SHELL_DOCTRINE.md`;
- PR #143's seven-slot component contract;
- `lifepunchaddons/docs/branding/OPS_CRT_TERMINAL_THEMES.md`;
- the existing `LpOpsCrtTheme.BlackMarket` stub; and
- `.claude/skills/lifepunch-design-tokens/SKILL.md`.

The doctrine's §7 contradiction flags remain open. This specification consumes the ruled slot
subset and does not resolve, reinterpret, or duplicate either flagged shell-chrome decision.

## 2. Storefront identity and prior-art reconciliation

`LpOpsCrtTheme.BlackMarket` is prior art for a **typed-command CRT terminal**: a black shell with
light text. The dealer storefront is a **modern clickable `LpMenuShell` consumer**. Phase B must:

- preserve the prior art's near-black, restrained, illicit-market tone;
- use the shared shell's surfaces, spacing, footer, route chrome, and interaction grammar;
- not apply `lp-ops-crt` or `lp-ops-crt--blackmarket` to the storefront;
- not copy or fork `LpOpsCrtTerminal.scss`;
- not create a second Black Market theme constant merely for the storefront; and
- leave a future command terminal free to continue using `LpOpsCrtTheme.BlackMarket`.

The storefront consumer supplies one high-contrast `AccentColor` token. Its final product color is
a Phase B design input, not decided here; it must not be green (cash semantic), white (structural),
or black against the black shell. Headings and buttons use **Poppins**. Labels, body copy, and values
use **Inter**. **Montserrat must never be declared in in-game SCSS.**

The mark is dealer-owned job art. It must not use the LP roundel, which is reserved for Player Hub.

## 3. Slot-by-slot requirements

| # | Slot | Razor type | Dealer storefront requirement | Required state behavior |
|---|---|---|---|---|
| 1 | `Mark` | `RenderFragment` | Render one dealer-owned, non-LP mark with a stable footprint and visible text alternative beside it in shared chrome. | Static; if art is unavailable, render a restrained `BM` fallback rather than an empty identity block. |
| 2 | `Wordmark` | `string` | Use `BLACK MARKET` as the product wordmark. The shell derives its eyebrow/footer identity from this value. | Non-empty at first render; no loading variant. |
| 3 | `TopBarControls` | `RenderFragment` | Show storefront availability, catalog synchronization state, and refresh status. It may expose refresh/navigation controls, but no buy, sell, debit, payout, or cashout action. | While loading, controls are disabled and labeled `LOADING CATALOG`; on failure, show `CATALOG OFFLINE` plus a retry affordance. |
| 4 | `NavItems` | `List<NavItem>` | Provide `Overview`, `Catalog`, `Inventory`, `Orders`, `Dead Drops`, and bottom-pinned `Settings`. Exactly one item is active. `Overview` alone sets `IsDashboard=true`; `Settings` alone sets `IsSettings=true`. | Routes whose contracts are unavailable remain visible but disabled with a clear tooltip; loading never changes route identity or order. |
| 5 | `DoorCards` | `List<DoorCard>` | On Overview, route to `Catalog`, `Orders`, and `Dead Drops`. Cards summarize availability only; they do not execute a transaction. | Loading uses disabled cards with `Info` chips; empty catalog uses a disabled `NO LISTINGS` card; unavailable dependencies use `Locked`, not a fake zero. |
| 6 | `SnapshotStats` | `List<StatRow>` | Show four read-only operational facts: catalog status, listing count, open-order count, and available drop count. Do not show a writable balance. | Loading values use `—` plus `Loading`; unavailable values use `—` plus a reason; legitimate counts may display `0`. |
| 7 | `QuickButtons` | `List<QuickButton>` | Provide exactly three shortcuts: `Browse Catalog`, `View Orders`, and `Dead Drops`. Each switches route only. | Disable a shortcut while its route is unavailable. No shortcut may purchase, fence, sell, or transfer value. |

### 3.1 Separate accent parameter

`AccentColor` is a separate `[Property]`, not an eighth content slot. The consumer passes one
parser-safe color token. The shared shell owns where it is applied. The storefront must not add
per-slot accent parameters or raw color decisions to slot models.

### 3.2 Shared chrome remains shell-owned

The consumer does not replace or parameterize the sidebar frame, top bar, eyebrow, page-title
frame, callout frame, dashboard snapshot frame, quick-button row frame, footer, outer radius, or
clipping. It supplies data to the existing apertures only.

## 4. Slot data contracts

The following are consumer view-model requirements mapped onto PR #143's existing shell types.
They do not amend the shared component.

### 4.1 `Mark`

```text
DealerMarkView {
  Fragment: RenderFragment
  FallbackText: "BM"
}
```

The fragment is present from first render. Asset loading must not resize the identity block.

### 4.2 `Wordmark`

```text
Wordmark: "BLACK MARKET"
```

This is display identity only. It does not decide the package ident, job model, or publish name.

### 4.3 `TopBarControls`

```text
StorefrontHeaderView {
  Availability: enum { Loading, Online, Offline, Locked }
  CatalogStateLabel: string
  LastRefreshLabel: string
  CanRefresh: bool
  OnRefresh: Action?
}
```

No balance, price mutation, or transaction callback belongs in this fragment.

### 4.4 `NavItems`

Each entry uses the existing `NavItem` fields:
`Route`, `Label`, `Icon`, `Tooltip`, `PageIcon`, `PageTitle`, `Callout`, `IsActive`,
`IsSettings`, `IsDashboard`, `HasAlert`, `Enabled`, and `OnSelected`.

Required route keys are stable consumer constants:

| Route | Page title | Dashboard | Settings | Phase A behavior |
|---|---|---:|---:|---|
| `overview` | Market Overview | Yes | No | Available shell landing route |
| `catalog` | Catalog | No | No | Browse-only; price rules in §6 |
| `inventory` | Inventory | No | No | Read-only stock presentation |
| `orders` | Orders | No | No | Read-only order status |
| `dead-drops` | Dead Drops | No | No | Route only; no placement contract here |
| `settings` | Settings | No | Yes | Bottom-pinned shell route |

Authorization is supplied by the future consumer. This specification does not decide whether the
storefront is dealer-only or public.

### 4.5 `DoorCards`

Cards use the existing `DoorCard` and `StatusChip` fields. Consumer semantics are:

```text
StorefrontDoorCardInput {
  Route: "catalog" | "orders" | "dead-drops"
  Title: string
  Description: string
  Label: string
  Availability: enum { Loading, Available, Empty, Locked, Offline }
  Count: int?
  OnSelected: Action?
}
```

The adapter maps `Availability` to existing `StatusChipVariant` values:
`Available`/non-zero count → `Count`; `Loading`/`Offline` → `Info`; `Empty`/`Locked` → `Locked`.
`Enabled` is true only when the destination route is usable.

### 4.6 `SnapshotStats`

Each row maps to existing `StatRow` fields. The consumer provides:

```text
StorefrontStatInput {
  Key: "catalog-status" | "listing-count" | "open-orders" | "drop-slots"
  Label: string
  DisplayValue: string
  Description: string
  State: enum { Loading, Ready, Unavailable }
}
```

These are display values, not authoritative economy storage. A legitimate zero is distinct from
an unavailable value.

### 4.7 `QuickButtons`

Each button uses the existing `QuickButton` fields:
`Label`, `Icon`, `Route`, `CssClass`, `Enabled`, and `OnSelected`.
Callbacks perform route selection only.

## 5. Non-dashboard pane contracts

Pane bodies render through inherited `ChildContent`; they are not additional shell slots.

| Route | Minimum read-only data | Empty state | Loading/error state |
|---|---|---|---|
| Catalog | Item name, category, availability, optional authoritative display price | `NO LISTINGS AVAILABLE` with no transaction control | Stable rows labeled `LOADING CATALOG`; failure shows `CATALOG OFFLINE` and retry |
| Inventory | Item name and stock count | `NO STOCK RECORDED` | `LOADING INVENTORY`; unavailable reason is explicit |
| Orders | Order reference, item label, status label | `NO OPEN ORDERS` | `LOADING ORDERS`; failed lookup never appears as zero orders |
| Dead Drops | Drop reference, availability/status, location label only when authorized | `NO DEAD DROPS AVAILABLE` | `LOADING DEAD DROPS`; unavailable contract remains locked |
| Settings | Consumer-owned non-economy preferences only | `NO SETTINGS AVAILABLE` | Disabled controls with a plain failure label |

Loading placeholders reserve final row/card space, carry visible text, and expose no active primary
action. State must never be communicated by color alone.

## 6. Price and purchase gate — BM-S4

Prices are a **read-only presentation dependency** on BM-S4:

1. Before BM-S4 defines an authoritative price contract, the storefront displays
   `PRICING UNAVAILABLE — BM-S4 PENDING`; it must not invent, cache, calculate, or hardcode prices.
2. After BM-S4 supplies authoritative display data, Catalog may render a preformatted
   `DisplayPrice` and currency identity exactly as provided. The pane does not recompute it.
3. Phase A defines no purchase callback. Until a later authorized economy slice, buy controls are
   absent or disabled and labeled `PURCHASE UNAVAILABLE`.
4. No slot or pane accepts a client-authored amount, balance, recipient, payout, margin, or rail.
5. Currency rendering must follow Law 17: BTC identity uses gold/bitcoin-orange, DXRP cash uses
   green only for the `$` currency sign, amount text remains white, and color is not the only cue.

This specification does not choose a BTC source, grant path, market row, dealer margin, wallet, or
atomicity/idempotency mechanism.

## 7. Accessibility and interaction requirements

- Interactive targets are at least 44px with at least 8px between controls.
- Disabled and loading controls include visible text, not only reduced opacity.
- Focus and selected-route states remain visible at storefront contrast levels.
- Icons supplement labels; they never replace essential text.
- The page uses one scroll region per route.
- No decorative animation is required.

## 8. Explicit non-goals

- No `.razor`, `.razor.scss`, `.scss`, C#, prefab, ModelDoc, config, portal, or runtime work.
- No Phase B implementation before #135 / PR #143 merges and a conductor LIVE instruction.
- No bespoke shell, eighth slot, local `ChildContent` property, or fork of shell chrome.
- No resolution of either `UNIVERSAL_MENU_SHELL_DOCTRINE.md` §7 contradiction flag.
- No purchase, debit, credit, payout, cashout, transfer, grant, stock mutation, or ledger design.
- No fencing or stolen-goods UI. R6 is open and remains a hard blocker.
- No laundering UI or Banker-lane contract.
- No decision on R2–R8, including job model, payment rail, grant path, publish ident, or Player Hub
  overlap.
- No command-terminal design and no changes to `LpOpsCrtTheme.BlackMarket`.
- No claim that the Black Market Dealer storefront has compiled, rendered, or passed play proof.

## 9. Phase B entry conditions

Phase B remains gated until all of the following are true:

- #135 is merged and the seven-slot shell contract is available on the target base;
- the conductor posts a Phase B LIVE instruction;
- BM-S4 has supplied any price data the storefront is expected to display;
- unresolved routes are explicitly disabled rather than locally invented; and
- implementation scope names the exact consumer files without touching the CRT theme source.

Until then, this document is the complete BM-S5 Phase A deliverable.
