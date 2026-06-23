# YouTube descriptions

Source of truth for YouTube description copy on every LifePunch addon showcase upload.

Canon: `lifepunch/addons/docs/PUBLISHING.md` § YouTube.

## How to use

1. Copy `TEMPLATE.md` to `<packageSlug>-v<semver>-r<portalRev>.md` (e.g. `lifepunchulx-v1.0.2-r8.md`).
2. Fill every `{{PLACEHOLDER}}` with addon-specific copy.
3. Add matching tags in `tags/<packageSlug>-v<semver>-r<portalRev>.txt` (comma-separated; YouTube Tags field only — no `#`).
4. Paste the description body (everything **below** the leading HTML comment) into YouTube.
5. Update **CHAPTERS** timestamps after final edit.

## Conventions

- **Footer:** `FOOTER.md` — fixed ENJOY / LINKS / network / IP block on every upload; swap portal URL + description hashtags only.
- **Description file:** `<packageSlug>-v<semver>-r<portalRev>.md`
- **Tags file:** `tags/<packageSlug>-v<semver>-r<portalRev>.txt` (primary SEO set)
- **Extended tags:** `tags/<packageSlug>-v<semver>-r<portalRev>-extended.txt` (swap pool — YouTube ~500 char cap; mix with primary)
- Section dividers: box-drawing bars (`════`, `────`, `━━━━━━━━`) per `TEMPLATE.md` v2.
- Proprietary notice required on every upload — public counterpart to the in-code header.
- Author credit: `Bloodwave | mrragerlp | lifepunch.co` unless a different uploader publishes.

## Index

| File | Purpose |
|------|---------|
| `FOOTER.md` | **Shared footer** — ENJOY box, links, network box, IP line (all videos) |
| `lifepunchulx-v1.0.2-r8.md` | **lifepunchulx** showcase — v1.0.2 portal r8 (current) |
| `tags/lifepunchulx-v1.0.2-r8.txt` | Primary tags (SEO / feature set) |
| `tags/lifepunchulx-v1.0.2-r8-extended.txt` | Extended / swap pool (platform + discovery) |
| `lifepunch.ulx-v1.md` | **Superseded** — pre-rename draft (`lifepunch.ulx`); use `lifepunchulx-v1.0.2-r8.md` |
