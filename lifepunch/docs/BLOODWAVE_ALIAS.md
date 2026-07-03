# Bloodwave — owner alias (June 2026)

Canon for agents, proprietary headers, and CVL. Read with `MACHINE_CAST.md`.

---

## Why Bloodwave

**Bloodwave** is the owner's visible community name — an homage to the original **Bloodwave**
who led a **DarkRP (Garry's Mod)** community. Jared worked under that Bloodwave for nearly a decade;
when he disappeared, the community lost its anchor. LifePunch is the owner's attempt to rebuild
that spirit of serious development — not impersonation, but respect carried forward.

**Mr. Rager / mrragerlp** remains how people know Jared through email, accounts, and legacy contact.
**Bloodwave** is the public face for in-game, Steam, Discord, and new community work.

---

## Three layers (do not mix)

| Layer | Identifier | Use when |
|-------|------------|----------|
| **Legal / proprietary author** | **mrragerlp** · **mrragerlp@lifepunch.co** | Proprietary headers, code ownership notes, legal contact on IP |
| **Visible / in-game** | **Bloodwave** | s&box, Steam, Discord display; agent chat; community |
| **Contact / recognition** | **Mr. Rager** | Legacy contact — still valid; same person |
| **Git commits (GitHub)** | **mragerlp** · **mragerlp@gmail.com** | `git commit` author on monorepo — infrastructure handle, not the legal display name |

**IP entity** remains **lifepunch.co** (Peak Performance Products LLC) on all proprietary headers.

---

## Proprietary header (every `.cs` / `.razor` / `.scss`)

After `EXCEPT the owner (lifepunch.co).` add:

```text
Author account: mrragerlp (mrragerlp@lifepunch.co) · Public alias (in-game · Steam · Discord): Bloodwave
```

Template: `.cursor/rules/dxrp-addon-foundation.mdc`

---

## Accounts & paths (unchanged)

| Context | Value |
|---------|--------|
| GitHub monorepo remote | `github.com/mragerlp/lifepunch` |
| GitHub username | **`mragerlp`** — keep; do **not** rename to `bloodwave` (see below) |
| GitHub display name | **Bloodwave** (profile only — no URL change) |
| Legal / code author | **mrragerlp** · **mrragerlp@lifepunch.co** |
| Git commit author | **mragerlp** · **mragerlp@gmail.com** (monorepo commits only) |
| Windows login | `jared` |
| USPTO / LLC | Jared Zerillo · Peak Performance Products LLC |

---

## GitHub username — keep `mragerlp` (June 2026 decision)

**Bloodwave** is the public/community alias. **`mragerlp`** is the infrastructure handle.

Do **not** change the GitHub account username to `bloodwave`:

| Reason | Detail |
|--------|--------|
| **Redirects are fragile** | [GitHub username changes](https://docs.github.com/en/account-and-profile/concepts/username-changes) redirect repos briefly; if someone claims `mragerlp` and recreates a repo name, redirects break |
| **Wired everywhere** | `lifepunch`, `lifepunch-published`, `dxrp-public`, agent prompts, DXRP pin config, partner clones |
| **Three-layer law** | Bloodwave = visible; mrragerlp = author; lifepunch.co = IP — username rename conflates layers |
| **GitLab separate** | `gitlab.com/mragerlp` is unrelated to a GitHub rename — more drift, no benefit |

**Do instead:** GitHub profile **display name** = Bloodwave; keep all `github.com/mragerlp/...` remotes as-is. Optional future: GitHub **org** (`lifepunch` or `bloodwave`) for public repos only — personal account stays `mragerlp`.

---

## Agent law

1. **Agent prose:** Bloodwave.
2. **Proprietary / code:** **mrragerlp** (`mrragerlp@lifepunch.co`) as legal author; lifepunch.co as IP owner.
3. **Do not** rename GitHub URLs or Windows paths.
4. **Email / Mr. Rager:** fine for contact context — not the in-game or Discord display name.

---

## Uniform (avatar)

| File | Use |
|------|-----|
| `branding/lifepunch-ops/outfits/bloodwave/bloodwave-avatar-1024.png` | Canonical |
| `branding/lifepunch-ops/outfits/bloodwave/bloodwave-avatar-500.png` | Discord · Steam · profiles |

Split portrait — Mr. Rager / Bloodwave, same person. See `outfits/bloodwave/README.md`.
