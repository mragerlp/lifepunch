# YouTube descriptions

Source of truth for the YouTube description copy used on every LifePunch addon showcase upload.

## How to use

1. Copy `TEMPLATE.md` to `<addon-ident>-v<version>.md` (e.g. `ak47-v1.md`).
2. Fill every `{{PLACEHOLDER}}` with addon-specific copy.
3. Leave the **fixed footer blocks** untouched — they must be identical on every upload:
   - the `Enjoy ⛶` sign-off + author credit line,
   - the links block (DXRP / Website / Discord / Steam / s&box),
   - the proprietary / IP notice (swap only the addon name).
4. Paste the body (everything below the leading HTML comment) into the YouTube description.

## Conventions

- One file per published video, named `<addon-ident>-v<version>.md`.
- Section dividers use the 28-char em-dash bar: `━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`.
- The proprietary notice is **required** on every description from here on out — it is the public-facing
  counterpart to the in-code proprietary header (see `.cursor/rules/dxrp-addon-foundation.mdc`).
- Author credit defaults to the owner (`Mr. Rager | mrragerlp | lifepunch.co`); change only if a
  different uploader publishes the video.

## Index

- `lifepunch.ulx-v1.md` — DXRP staff menu (portal package "DXRP Admin Menu", s&box ident `lifepunch.ulx`).
