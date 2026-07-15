# Banker menu — LpMenuShell slot specification

**Phase:** BANKER-S5 Phase A · documentation only

**Issue:** #142 · **Build gate:** Phase B remains gated on #135

**Contract source:** PR #143 (`LpMenuShell` seven-slot extraction)

This document specifies the Banker's menu as a consumer of the shared `LpMenuShell`. It does not
authorize Razor, SCSS, balance reads, or economy mutations. The shell remains responsible for all
shared chrome.

## Ruled boundaries

- The consumer supplies exactly the seven named slots from PR #143: `Mark`, `Wordmark`,
  `TopBarControls`, `NavItems`, `DoorCards`, `SnapshotStats`, and `QuickButtons`.
- `AccentColor` is the shell's separate eighth property, not an eighth content slot.
- The inherited panel aperture carries non-dashboard pane content; the Banker must not declare a
  second `ChildContent`.
- `BuildHash` must cover every supplied slot and `AccentColor` when Phase B is authorized.
- The consumer takes no position on the two contradiction flags in
  `UNIVERSAL_MENU_SHELL_DOCTRINE.md` §7. Identity-block position and active-nav accent-strip behavior
  remain shell-owned and are consumed exactly as #135 lands.
- The proprietary footer, Dashboard naming, and shell-owned copy-to-`lifepunch.co` behavior follow
  `POLISH_RULINGS_2026-07-15.md`. The Banker does not replace or parameterize them.

## Slot requirements

| # | Slot | Used | Banker requirement | Empty state | Loading state |
|---|---|---:|---|---|---|
| 1 | `Mark` | Yes | Bank-owned vault/branch mark; never the Player Hub LP roundel | Neutral bank glyph with `BANKER` text label | Static mark; no animated loader |
| 2 | `Wordmark` | Yes | Exact string `BANKER OPERATIONS` | Not permitted; configuration error | Static string; never delayed |
| 3 | `TopBarControls` | Yes | Read-only service state; authoritative balance may be added only after BANKER-S4 | `SERVICES UNAVAILABLE`; no numeric fallback | `CONNECTING`; reserve balance width, show no amount |
| 4 | `NavItems` | Yes | Dashboard-first route list with Settings pinned by the shell; no top-level Upgrades item | Dashboard + Settings only | Stable disabled route labels until route readiness resolves |
| 5 | `DoorCards` | Yes | Navigation cards for ruled Banker capabilities; cards may advertise no unruled money action | `NO BANK SERVICES AVAILABLE` | Fixed card placeholders with `CHECKING SERVICE` |
| 6 | `SnapshotStats` | Yes | Three or four read-only branch/service facts; balance omitted until BANKER-S4 | Labelled em dashes, never zeroes | Preserve row labels; values read `CHECKING` |
| 7 | `QuickButtons` | Yes | Exactly three navigation shortcuts; no deposit, withdraw, transfer, or approval action | Disabled shortcuts with `UNAVAILABLE` reason | Disabled buttons labelled `CHECKING` |

## Slot data contracts

The headings below retain PR #143's shell property types (`RenderFragment`, `string`, or the named
list type). Fields under fragment-backed slots define the Banker's consumer-side view model and
rendering obligations; they do not add properties to `LpMenuShell`.

### 1. `Mark`

| Field | Type | Required | Contract |
|---|---|---:|---|
| `Content` | `RenderFragment` | Yes | One bank-owned mark or glyph plus visible text fallback |
| `AccessibleLabel` | `string` | Yes | `Banker Operations`; visible when the mark cannot render |
| `State` | `enum` | Yes | `Ready` or `Fallback`; no money or service state encoded by color alone |

### 2. `Wordmark`

| Field | Type | Required | Contract |
|---|---|---:|---|
| `Text` | `string` | Yes | Constant `BANKER OPERATIONS` |

### 3. `TopBarControls`

| Field | Type | Required | Contract |
|---|---|---:|---|
| `ServiceState` | `enum` | Yes | `Connecting`, `Online`, `Degraded`, or `Unavailable` |
| `ServiceLabel` | `string` | Yes | Human-readable state; color is never the only signal |
| `BalanceState` | `enum` | Yes | `Gated`, `Loading`, `Available`, or `Unavailable` |
| `BalanceText` | `string?` | Conditional | Host-authoritative, formatted read-only value; only legal after BANKER-S4 |
| `BalanceCurrency` | `enum?` | Conditional | Declared authoritative rail; never inferred by the client |
| `BalanceAsOf` | `DateTime?` | Conditional | Timestamp for an available authoritative snapshot |

`Gated` and `Unavailable` render text, not `$0`. No top-bar control mutates money in Phase B.

### 4. `NavItems`

| Field | Type | Required | Contract |
|---|---|---:|---|
| `Id` | `string` | Yes | Stable route identifier |
| `Label` | `string` | Yes | Uses `Dashboard`, never `Overview` |
| `Icon` | `RenderFragment` | Yes | Non-emoji icon with visible label |
| `Route` | `string` | Yes | Local pane target |
| `Enabled` | `bool` | Yes | False until the pane's backing contract exists |
| `UnavailableReason` | `string?` | Conditional | Required when disabled |
| `IsSettings` | `bool` | Yes | Exactly one item; shell pins it at the bottom |

The list must not contain a top-level `Upgrades` entry. Additional route names require a later ruled
Banker capability contract; Phase A does not invent them.

### 5. `DoorCards`

| Field | Type | Required | Contract |
|---|---|---:|---|
| `Id` | `string` | Yes | Stable capability identifier |
| `Icon` | `RenderFragment` | Yes | Capability-specific, non-emoji icon |
| `Title` | `string` | Yes | Ruled capability name |
| `Chips` | `List<StatusChip>` | Yes | Readiness/count facts only |
| `Description` | `string` | Yes | One-line capability description |
| `Label` | `string` | Yes | Right-side state label |
| `Route` | `string` | Yes | Navigation target only |
| `Enabled` | `bool` | Yes | False when the capability or its contract is gated |

`StatusChip` carries `Text` and one of `Info`, `Success`, `Locked`, or `Count`. A locked card must
explain its gate and must not expose an action callback.

### 6. `SnapshotStats`

| Field | Type | Required | Contract |
|---|---|---:|---|
| `Id` | `string` | Yes | Stable statistic identifier |
| `Label` | `string` | Yes | Plain-language fact name |
| `Value` | `string?` | Conditional | Read-only authoritative value; null while gated/loading |
| `State` | `enum` | Yes | `Gated`, `Loading`, `Available`, or `Unavailable` |
| `Semantic` | `enum` | Yes | `Neutral`, `Positive`, `Warning`, or `Critical`; always paired with text |
| `AsOf` | `DateTime?` | Conditional | Required for live authoritative values |

Balance rows are prohibited until BANKER-S4. Missing data renders a labelled em dash or state text,
never a fabricated zero.

### 7. `QuickButtons`

| Field | Type | Required | Contract |
|---|---|---:|---|
| `Id` | `string` | Yes | Stable shortcut identifier |
| `Label` | `string` | Yes | Navigation destination |
| `Icon` | `RenderFragment` | Yes | Non-emoji icon |
| `Route` | `string` | Yes | Local pane target |
| `Enabled` | `bool` | Yes | False until destination is available |
| `UnavailableReason` | `string?` | Conditional | Required when disabled |

Quick buttons only navigate. They never submit deposits, withdrawals, transfers, approvals, or
lockdowns.

## Visual token contract

- HASHD-adjacent means a restrained black/surface/inset shell with structural borders and a single
  Banker gold/amber accent passed through `AccentColor`; it does not copy the HASHD CRT.
- Phase B must use named LIFEPUNCH tokens rather than raw component hex values. The accent must not
  be green or white.
- Poppins is required for headings and buttons. Inter is required for labels, body text, and values.
  **Montserrat must never be declared in in-game SCSS.**
- Currency follows Law 17: a DXRP `$` sign is green, amount text is white, and separators/units are
  white. Color never substitutes for a state label.
- Controls meet the 44px minimum target, use visible labels and focus treatment, and keep one scroll
  region per pane.

## BANKER-S4 balance gate

Every balance figure is read-only and remains absent until BANKER-S4 supplies and approves the
authoritative rail and read contract. This spec does not choose vault versus native bank, cash versus
`$LP`, fee behavior, or any source of truth. Before that gate, the shell renders `BALANCE GATED` or
`BALANCE UNAVAILABLE`; it must never display fixture data, cached client claims, or `$0` as a
substitute.

## Non-goals

- No Razor, SCSS, component, prefab, entity, or gameplay implementation.
- No resolution of `UNIVERSAL_MENU_SHELL_DOCTRINE.md` §7 contradiction flags.
- No copied or forked shell chrome; Phase B consumes `LpMenuShell` after #135 lands.
- No economy mutation, deposit, withdrawal, transfer, fee, interest, payout, approval, or ledger
  design.
- No choice between DXRP native bank and a separate vault ledger.
- No `$LP`, BTC, vault-heist, security-response, job-registration, or progression ruling.
- No top-level Upgrades navigation and no new shared-shell slot.
- No runtime, editor, visual, compile, or playtest claim from this documentation phase.
