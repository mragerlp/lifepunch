# DXRP Publish Staging

Publish staging is generated output. It is not the source of truth.

The source folders are:

```text
Assets/addons/lifepunch/<ident>/
Code/Addons/lifepunch/<ident>/
```

The generated upload root must preserve the DXRP game project shape:

```text
.dxrp-publish/upload/
  Assets/addons/lifepunch/<ident>/
  Code/Addons/lifepunch/<ident>/
```

Do not create or upload old flat folders:

```text
upload-assets/
upload-code/
```

## Generate Staging

```powershell
.\scripts\prepare-publish.ps1 -Addon ak47
```

The script reads `config/addons.json`, validates the repo, creates `.dxrp-publish/upload`, and copies only the selected addon's mounted asset/code folders.

It also writes `.dxrp-publish/package-<ident>.json` with the package identity and content-row values to use when checking the DXRP portal fields.

For `hasCode=false` addons, publish assets and reuse the previous code revision on DXRP if the portal asks for code.

For `hasAssets=false` addons, publish code only.

## YouTube Showcase Copy

The YouTube description for each showcase video is kept in the repo, not improvised per upload:

```text
../../marketing/youtube/TEMPLATE.md          # body template (WHAT IT IS / FEATURES / SETUP / CHAPTERS)
../../marketing/youtube/FOOTER.md            # fixed footer — ENJOY, links, network box, IP (all videos)
../../marketing/youtube/<ident>-v<version>.md # filled, paste-ready description per video
../../marketing/youtube/tags/<ident>-*.txt   # YouTube Tags field (comma-separated, no #)
```

Every description must carry the fixed footer blocks and the proprietary / IP notice (the public-facing
counterpart to the in-code proprietary header). See `../../marketing/youtube/README.md`.

## Portal Separation

Publishing an addon package revision is not the same thing as attaching it to a gamemode.

Review `../../docs/DXRP_DOCS_REFERENCE.md` and **`../../server/LAUNCHING_SERVER_WITH_ADDONS.md`** before changing publish/server assumptions. Published addons reach dedicated hosts only via portal **Add to Server** + `dxrp-server.cs` API pull — not by copying repo folders onto lifepunchnet.

Keep these steps separate:

1. Publish addon package revision from generated staging.
2. Add or update content rows from the manifest/exported content data.
3. Attach/pin the addon revision on the LifePunch gamemode.
4. Add equipment, market, or job rows only in the gamemode layer.
5. Sync the development server before assuming runtime behavior.
